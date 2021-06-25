//
//  TrackListViewController.swift
//  Sandsara
//
//  Created by Tín Phan on 11/12/20.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class TrackListViewController: BaseVMViewController<TrackListViewModel, NoInputParam> {

    @IBOutlet private weak var tableView: UITableView!

    private let viewWillAppearTrigger = PublishRelay<()>()

    private let downloadBtnTrigger = PublishRelay<()>()

    private let syncBtnTrigger = PublishRelay<()>()

    typealias Section = SectionModel<String, PlaylistDetailCellVM>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    private lazy var dataSource: DataSource = self.makeDataSource()

    var playlistItem: DisplayItem?

    private var cellHeightsDictionary: [IndexPath: CGFloat] = [:]

    override func setupViewModel() {
        tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        setupTableView()
        viewModel = TrackListViewModel(apiService: SandsaraDataServices(),
                                       inputs: TrackListViewModelContract.Input(playlistItem: playlistItem ?? DisplayItem() ,
                                                                                viewWillAppearTrigger: viewWillAppearTrigger,
                                                                                downloadBtnTrigger: downloadBtnTrigger))
    
        viewWillAppearTrigger.accept(())
    }

    override func bindViewModel() {
        dataSource.canEditRowAtIndexPath = { (ds, ip) in
            return true
        }

        viewModel
            .outputs.datasources
            .map { [Section(model: "", items: $0)] }
            .doOnNext { [weak self] in
                if !$0.isEmpty {
                    self?.tableView.scrollsToTop = true
                }
            }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        tableView.rx.itemSelected.subscribeNext { [weak self] indexPath in
                guard let self = self else { return }
            if indexPath.row != 0 {
                self.openTrackDetail(index: indexPath.row)
            }
        }.disposed(by: disposeBag)

        if let item = playlistItem {
            if item.isLocal == true && item.title != L10n.favorite {
                tableView.rx.itemDeleted
                    .filter { $0.row != 0 && !self.viewModel.isEmpty }
                    .subscribeNext { [weak self] indexPath in
                    guard let self = self else { return }
                    self.viewModel.deleteTracks(index: indexPath.row)
                }.disposed(by: disposeBag)
            }
        }
    }

    private func setupTableView() {
        tableView.backgroundColor = Asset.background.color
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(TrackTableViewCell.nib, forCellReuseIdentifier: TrackTableViewCell.identifier)
        tableView.register(PlaylistHeaderTableViewCell.nib, forCellReuseIdentifier: PlaylistHeaderTableViewCell.identifier)
        tableView.register(EmptyCell.nib, forCellReuseIdentifier: EmptyCell.identifier)
        tableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
    }

    private func makeDataSource() -> DataSource {
        return RxTableViewSectionedReloadDataSource<Section>(
            configureCell: { (_, tableView, indexPath, viewModel) -> UITableViewCell in
                switch viewModel {
                case .header(let viewModel):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistHeaderTableViewCell.identifier, for: indexPath) as? PlaylistHeaderTableViewCell else { return UITableViewCell()}
                    cell.bind(to: viewModel)
                    cell.playlistTrigger.subscribeNext {
                        self.downloadBtnTrigger.accept(())
                    }.disposed(by: cell.disposeBag)
                    cell.playAction.subscribeNext {
                        self.openPlayer(index: 0)
                    }.disposed(by: cell.disposeBag)
                    cell.backAction.subscribeNext {
                        self.navigationController?.popViewController(animated: true)
                    }.disposed(by: cell.disposeBag)
                    cell.deleteAction.subscribeNext {
                        self.showDeletePlaylistAlert()
                    }.disposed(by: cell.disposeBag)
                    return cell
                case .track(let viewModel):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackTableViewCell.identifier, for: indexPath) as? TrackTableViewCell else { return UITableViewCell()}
                    cell.bind(to: viewModel)
                    return cell
                case .empty:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: EmptyCell.identifier, for: indexPath) as? EmptyCell else { return UITableViewCell() }
                    return cell
                }

            })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        NotificationCenter.default.removeObserver(self)
    }

    @objc func reloadData() {
        self.viewWillAppearTrigger.accept(())
    }

    private func openTrackDetail(index: Int) {
        let trackList = self.storyboard?.instantiateViewController(withIdentifier: TrackDetailViewController.identifier) as! TrackDetailViewController
        switch viewModel.datas.value[index] {
        case .track(let viewModel):
            trackList.track = viewModel.inputs.track
            trackList.tracks = self.viewModel.datas.value.map {
                switch $0 {
                case .track(let vm): return vm.inputs.track
                default: return nil
                }
            }.compactMap { $0 }
            trackList.playlistItem = self.playlistItem
        default:
            break
        }

        trackList.selecledIndex = index - 1
        self.navigationController?.pushViewController(trackList, animated: true)
    }

    private func openPlayer(index: Int) {
        let player = PlayerViewController.shared
        player.modalPresentationStyle = .fullScreen
        player.index = index
        player.tracks = self.viewModel.datas.value.map {
            switch $0 {
            case .track(let vm): return vm.inputs.track
            default: return nil
            }
        }.compactMap { $0 }
        player.playlingState = .playlist
        player.playlistItem = playlistItem
        player.isReloaded = true
        (tabBarController?.popupBar.customBarViewController as! PlayerBarViewController).state = .haveTrack(displayItem: player.tracks[index])
        tabBarController?.popupBar.isHidden = false
        tabBarController?.popupContentView.popupCloseButton.isHidden = true
        tabBarController?.presentPopupBar(withContentViewController: player, openPopup: true, animated: false, completion: nil)
    }

    private func showDeletePlaylistAlert() {
        guard let item = playlistItem else { return }
        let alert = UIAlertController(title: "Alert", message: L10n.alertDeletePlaylist, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: L10n.ok, style: .default, handler: { _ in
            if !item.isLocal || item.isTestPlaylist {
                _ = DataLayer.deleteDownloadedPlaylist(item.title)
            } else {
                _ = DataLayer.deletePlaylist(item.title)
            }
            self.navigationController?.popViewController(animated: true)
        }))

        alert.addAction(UIAlertAction(title: L10n.cancel, style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }
}


extension TrackListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeightsDictionary[indexPath] = cell.frame.size.height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeightsDictionary[indexPath] ?? UITableView.automaticDimension
    }
}
