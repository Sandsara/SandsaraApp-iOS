//
//  AddPlaylistViewModel.swift
//  Sandsara
//
//  Created by Tín Phan on 23/11/2020.
//

import RxSwift
import RxCocoa

final class AddPlaylistViewModel: BaseViewModel<PlaylistViewModelContract.Input, PlaylistViewModelContract.Output> {
    let datas = BehaviorRelay<[PlaylistCellViewModel]>(value: [])

    override func transform() {
        inputs.viewWillAppearTrigger.subscribeNext { [weak self] in
            guard let self = self else { return }
            self.buildCellVM()
        }.disposed(by: disposeBag)

        setOutput(Output(datasources: datas.asDriver()))
    }

    
    /// Load latest data of local playlist, favorite playlist, downloaded playlist
    private func buildCellVM()  {
        var items = [PlaylistCellViewModel]()
        if let favList = DataLayer.loadFavList(), !favList.tracks.isEmpty {
            items.append(PlaylistCellViewModel(inputs: PlaylistCellVMContract.Input(track: DisplayItem(playlist: favList), isFavorite: true)))
        }
        if DataLayer.loadPlaylists().count > 0 {
            let localList = DataLayer.loadPlaylists().map {
                DisplayItem(playlist: $0)
            }.map {
                PlaylistCellViewModel(inputs: PlaylistCellVMContract.Input(track: $0, isFavorite: false))
            }
            items.append(contentsOf: localList)
        }

        if DataLayer.loadDownloaedPlaylists().count > 0 {
            let localList = DataLayer.loadDownloaedPlaylists().map {
                DisplayItem(playlist: $0)
            }.map {
                PlaylistCellViewModel(inputs: PlaylistCellVMContract.Input(track: $0, isFavorite: false))
            }
            items.append(contentsOf: localList)
        }

        datas.accept(items)
    }
}

