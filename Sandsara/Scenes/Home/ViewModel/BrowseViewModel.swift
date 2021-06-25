//
//  BrowseViewModel.swift
//  Sandsara
//
//  Created by tin on 5/18/20.
//  Copyright © 2020 tin. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

// MARK: DiscoverSection for recommended playlists/ tracks
enum DiscoverSection: CaseIterable {
    case recommendedPlaylists
    case recommendedTracks

    
    /// Title of section
    var title: String {
        switch self {
        case .recommendedPlaylists:
            return L10n.recommendedPlaylists
        case .recommendedTracks:
            return L10n.recommendedTracks
        }
    }
    
    
    /// Section height
    var sectionHeight: CGFloat {
        return 54.0
    }
}

enum BrowseVMContract {
    struct Input: InputType {
        let searchText: BehaviorRelay<String?>
        let cancelSearch: PublishRelay<()>
        let viewWillAppearTrigger: PublishRelay<()>
    }

    struct Output: OutputType {
        let datasources: Driver<[RecommendTableViewCellViewModel]>
    }
}

class BrowseViewModel: BaseViewModel<BrowseVMContract.Input, BrowseVMContract.Output> {

    private let apiService: SandsaraDataServices
    private let playlists = BehaviorRelay<[DisplayItem]>(value: [])
    private let tracks = BehaviorRelay<[DisplayItem]>(value: [])
    private let cachedPlaylists = BehaviorRelay<[DisplayItem]>(value: [])
    private let cachedTracks = BehaviorRelay<[DisplayItem]>(value: [])
    private var datasources: [RecommendTableViewCellViewModel]

    
    /// ViiewModel custom initial function
    /// - Parameters:
    ///   - apiService: put data services here
    ///   - inputs: init the input for viewmodel, for example BrowseVMContract.Input(searchText: inputTrigger, cancelSearch: cancelSearchTrigger, viewWillAppearTrigger: viewWillAppearTrigger)
    init(apiService: SandsaraDataServices, inputs: BaseViewModel<BrowseVMContract.Input, BrowseVMContract.Output>.Input) {
        self.apiService = apiService
        self.datasources = [RecommendTableViewCellViewModel(inputs: RecommendTableViewCellVMContract
                                                                .Input(section: .recommendedPlaylists, items: [])),
                            RecommendTableViewCellViewModel(inputs: RecommendTableViewCellVMContract
                                                                .Input(section: .recommendedTracks, items: []))]
        super.init(inputs: inputs)
    }

    override func transform() {
        // MARK: API trigger functon
        inputs.viewWillAppearTrigger
            .subscribeNext { [weak self] in
            guard let self = self else { return }
            self.emitEventLoading(true)
            /// Get recommended playlist first then do cache in local, and then call recommended tracks
            self.apiService
                .getRecommendedPlaylists(option: self.apiService.getServicesOption(for: .recommendedplaylist))
                .asObservable()
                .subscribeNext { playlists in
                    let playlists = playlists.map { DisplayItem(playlist: $0)}
                    self.cachedPlaylists.accept(playlists)
                    self.playlists.accept(playlists)
                    self.apiService
                        .getRecommendTracks(option: self.apiService.getServicesOption(for: .recommendedtracks))
                        .asObservable()
                        .subscribeNext { tracks in
                            let tracks = tracks.map { DisplayItem(track: $0) }
                            self.tracks.accept(tracks)
                            self.cachedTracks.accept(tracks)
                            self.emitEventLoading(false)
                        }.disposed(by: self.disposeBag)
                }.disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)

        /// Datasource combine the latest data of recommended playlists and recommended tracks
        let datasources = Driver.combineLatest(self.playlists.asDriver(onErrorJustReturn: (Preferences.PlaylistsDomain.recommendedPlaylists ?? []).map { DisplayItem(playlist: $0)}), self.tracks.asDriver(onErrorJustReturn: (Preferences.PlaylistsDomain.recommendTracks ?? []).map { DisplayItem(track: $0)})).map {
            return [RecommendTableViewCellViewModel(inputs: RecommendTableViewCellVMContract.Input(section: .recommendedPlaylists, items: $0)), RecommendTableViewCellViewModel(inputs: RecommendTableViewCellVMContract.Input(section: .recommendedTracks, items: $1))]
        }

        setOutput(Output(datasources: datasources))
    }
}
