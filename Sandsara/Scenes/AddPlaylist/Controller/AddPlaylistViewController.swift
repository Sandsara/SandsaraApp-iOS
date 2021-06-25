//
//  AddPlaylistViewController.swift
//  Sandsara
//
//  Created by Tín Phan on 23/11/2020.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SVProgressHUD

class AddPlaylistViewController: BaseVMViewController<AddPlaylistViewModel, NoInputParam> {
    // MARK: Outlet connections between swift file and xib/ storyboard file
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.separatorStyle = .none
            tableView.tableFooterView = UIView()
            tableView.register(PlaylistTableViewCell.nib,
                               forCellReuseIdentifier: PlaylistTableViewCell.identifier)
        }
    }
    @IBOutlet private weak var backBtn: UIBarButtonItem!
    @IBOutlet private weak var addBtn: UIBarButtonItem!

    // MARK: - Properties
    var item: DisplayItem?
    let viewWillAppearTrigger = PublishRelay<()>()
    typealias Section = SectionModel<String, PlaylistCellViewModel>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    private lazy var dataSource: DataSource = self.makeDataSource()


    private var cellHeightsDictionary: [IndexPath: CGFloat] = [:]

    override func setupViewModel() {
        navigationItem.title = L10n.playlists
        viewModel = AddPlaylistViewModel(inputs: PlaylistViewModelContract.Input(mode: .local, viewWillAppearTrigger: viewWillAppearTrigger, searchTrigger: nil))
        viewWillAppearTrigger.accept(())
    }

    override func bindViewModel() {
        viewModel
            .outputs.datasources
            .map { [Section(model: "", items: $0)] }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        // MARK: Tableview selection handle
        Observable
            .zip(
                tableView.rx.itemSelected,
                tableView.rx.modelSelected(PlaylistCellViewModel.self)
            ).bind { [weak self] indexPath, model in
                guard let self = self else { return }
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.addPlaylistItem(model: model)
            }.disposed(by: disposeBag)

        viewModel.isLoading
            .drive(loadingActivity.rx.isAnimating)
            .disposed(by: disposeBag)

        backBtn.rx.tap.asDriver().driveNext {
            self.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)

        addBtn.rx.tap.asDriver().driveNext {
            self.showAlertAddItem()
        }.disposed(by: disposeBag)
    }

    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()

        tableView.register(PlaylistTableViewCell.nib, forCellReuseIdentifier: PlaylistTableViewCell.identifier)
        tableView.backgroundColor = Asset.background.color
        tableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
    }

    private func makeDataSource() -> DataSource {
        return RxTableViewSectionedReloadDataSource<Section>(
            configureCell: { (_, tableView, indexPath, viewModel) -> UITableViewCell in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistTableViewCell.identifier, for: indexPath) as? PlaylistTableViewCell else { return UITableViewCell()}
                cell.bind(to: viewModel)
                return cell
            })
    }

    
    /// Show alert to input and create a new playlist
    private func showAlertAddItem() {
        guard let itemToAdd = item else { return }
        let alert = UIAlertController(title: nil, message: "Create new playlist", preferredStyle: .alert)

        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Enter your playlist name here"
        }

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: L10n.ok, style: .default, handler: { [weak alert] (_) in
            if let textField = alert?.textFields?[0]  {
                if let text = textField.text {
                    if text.isEmpty == false {
                        if DataLayer.createPlaylist(name: text, thumbnail: itemToAdd.thumbnail, author: itemToAdd.author) == false {
                            self.showErrorHUD(message: "Playlist existed")
                        } else {
                            self.showSuccessHUD(message: "Playlist \(text) added")
                            self.viewWillAppearTrigger.accept(())
                            guard let itemToAdd = self.item else { return }
                            let localTrack = LocalTrack(track: itemToAdd)
                            if DataLayer.addTrackToPlaylist(name: text, track: localTrack) {
                                self.showSuccessHUD(message: "Track \(itemToAdd.title) was added to Playlist \(text)")
                                self.dismiss(animated: true, completion: nil)
                            } else {
                                self.showErrorHUD(message: "Track \(itemToAdd.title) was existed in playlist")
                            }
                        }
                    }
                }
            }
        }))

        present(alert, animated: true, completion: nil)
    }
    
    
    /// Add track to playlist action
    /// - Parameter model: a track user want to add
    private func addPlaylistItem(model: PlaylistCellViewModel) {
        guard let itemToAdd = item else { return }
        let localTrack = LocalTrack(track: itemToAdd)
        if model.inputs.isFavorite {
            if !DataLayer.addTrackToFavoriteList(localTrack) {
                self.showSuccessHUD(message: "Track added to Favorite List")
                self.dismiss(animated: true, completion: nil)
            } else {
                self.showErrorHUD(message: "Track \(itemToAdd.title) was existed in Favorite List")
            }
        } else {
            if DataLayer.addTrackToPlaylist(name: model.inputs.track.title, track: localTrack) {
                self.showSuccessHUD(message: "Track \(itemToAdd.title) was added to Playlist \(model.inputs.track.title)")
                self.dismiss(animated: true, completion: nil)
            } else {
                self.showErrorHUD(message: "Track \(itemToAdd.title) was existed in playlist")
            }
        }
    }
}

// MARK: UITableViewDelegate, calculate height for cell and header, footer
extension AddPlaylistViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96.0
    }
}
