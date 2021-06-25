//
//  BrowseTrackViewController.swift
//  Sandsara
//
//  Created by Tín Phan on 07/01/2021.
//

import UIKit
import RxSwift
import RxDataSources
import RxCocoa

class BrowseTrackViewController: BaseVMViewController<AllTracksViewModel, NoInputParam> {

    // MARK: Outlet connection
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var noResultView: UIStackView!
    
    // MARK: Properties
    /// API trigger
    let viewWillAppearTrigger = PublishRelay<()>()
    
    /// ControllerMode to indicate the API and Data display
    var mode: ControllerMode = .search
    typealias Section = SectionModel<String, AllTrackCellVM>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    private lazy var dataSource: DataSource = self.makeDataSource()
    var playlistTitle: String?
    let syncAll = PublishRelay<()>()
    let searchTrigger = PublishRelay<String>()

    override func setupViewModel() {
        setupTableView()
        isPlaySingle = true
        viewModel = AllTracksViewModel(apiService: SandsaraDataServices(), inputs: AllTracksViewModelContract.Input(mode: mode, viewWillAppearTrigger: viewWillAppearTrigger, syncAll: syncAll, searchTrigger: searchTrigger))
    }

    override func bindViewModel() {
        viewModel
            .outputs.datasources
            .doOnNext {
                self.tableView.alpha = $0.isEmpty ? 0 : 1
                self.noResultView.alpha = $0.isEmpty ? 1 : 0
            }
            .map { [Section(model: "", items: $0)] }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        /// Tableview selection handler
        tableView.rx.itemSelected.subscribeNext { [weak self] indexPath in
            guard let self = self else { return }
            self.openTrackDetail(index: indexPath.row)
        }.disposed(by: disposeBag)

        viewModel.isLoading
            .drive(loadingActivity.rx.isAnimating)
            .disposed(by: disposeBag)
    }

    
    //MARK: Tableview setup
    private func setupTableView() {
        tableView.backgroundColor = Asset.background.color
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(TrackTableViewCell.nib, forCellReuseIdentifier: TrackTableViewCell.identifier)
        tableView.register(TrackCountTableViewCell.nib, forCellReuseIdentifier: TrackCountTableViewCell.identifier)
        tableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
    }

    private func makeDataSource() -> DataSource {
        return RxTableViewSectionedReloadDataSource<Section>(
            configureCell: { (_, tableView, indexPath, viewModel) -> UITableViewCell in
                switch viewModel {
                case .header(let viewModel):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackCountTableViewCell.identifier, for: indexPath) as? TrackCountTableViewCell else { return UITableViewCell()}
                    cell.bind(to: viewModel)
                    cell.playlistTrigger
                        .bind(to: self.syncAll)
                        .disposed(by: cell.disposeBag)
                    return cell
                case .track(let viewModel):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackTableViewCell.identifier, for: indexPath) as? TrackTableViewCell else { return UITableViewCell()}
                    cell.bind(to: viewModel)
                    return cell
                }
            })
    }
    
    
    /// Navigate to Track Detail
    /// - Parameter index: user's track selected index
    private func openTrackDetail(index: Int) {
        let trackList = self.storyboard?.instantiateViewController(withIdentifier: TrackDetailViewController.identifier) as! TrackDetailViewController
        switch viewModel.datas.value[index] {
        case .track(let viewModel):
            trackList.track = viewModel.inputs.track
            trackList.tracks = [viewModel.inputs.track]
        default:
            break
        }

        trackList.selecledIndex = index - 1
        self.navigationController?.pushViewController(trackList, animated: true)
    }
}
// MARK: UITableViewDelegate, calculate height for cell and header, footer
extension BrowseTrackViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96.0
    }
}
