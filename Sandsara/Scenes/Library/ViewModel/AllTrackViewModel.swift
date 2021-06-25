//
//  AllTrackViewModel.swift
//  Sandsara
//
//  Created by Tín Phan on 15/11/2020.
//

import UIKit
import RxCocoa
import RxSwift

enum AllTrackCellVM {
    case header(DownloadCellViewModel)
    case track(TrackCellViewModel)
}

enum AllTracksViewModelContract {
    struct Input: InputType {
        let mode: ControllerMode
        let viewWillAppearTrigger: PublishRelay<()>
        let syncAll: PublishRelay<()>
        let searchTrigger: PublishRelay<String>?
    }

    struct Output: OutputType {
        let datasources: Driver<[AllTrackCellVM]>
    }
}

final class AllTracksViewModel: BaseViewModel<AllTracksViewModelContract.Input, AllTracksViewModelContract.Output> {

    private let apiService: SandsaraDataServices
    let datas = BehaviorRelay<[AllTrackCellVM]>(value: [])

    private var tracks = [TrackCellViewModel]()


    init(apiService: SandsaraDataServices, inputs: BaseViewModel<AllTracksViewModelContract.Input, AllTracksViewModelContract.Output>.Input) {
        self.apiService = apiService
        super.init(inputs: inputs)
    }

    override func transform() {
        emitEventLoading(true)
        
        //MARK: API or local database fetch trigger
        inputs.viewWillAppearTrigger.subscribeNext { [weak self] in
            guard let self = self else { return }
            self.buildCellVM()
        }.disposed(by: disposeBag)

        //MARK: Search input trigger
        inputs.searchTrigger?.subscribeNext { [weak self] text in
            guard let self = self else { return }
            self.apiService.queryTracks(word: text).subscribeNext { values in
                let items = values.map { DisplayItem(track: $0) }.map { TrackCellViewModel(inputs: TrackCellVMContract.Input(mode: .remote, track: $0, saved: true)) }.map {
                    AllTrackCellVM.track($0)
                }
                self.datas.accept(items)
            }.disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)

        setOutput(Output(datasources: datas.asDriver()))
    }

    private func buildCellVM()  {
        var datas = [AllTrackCellVM]()
        // MARK: Fetch all user's downloaded tracks
        if inputs.mode == .local {
            let list = DataLayer.loadDownloadedTracks()
            let items = list.map { DisplayItem(track: $0) }.map { TrackCellViewModel(inputs: TrackCellVMContract.Input(track: $0, saved: DataLayer.checkTrackIsSynced($0))) }.map {
                AllTrackCellVM.track($0)
            }
            datas.append(contentsOf: items)
            self.datas.accept(datas)
            self.emitEventLoading(false)
        }
        // MARK: Get all tracks from airtable
        else {
            apiService.getAllTracks(option: .both).asObservable().subscribeNext { values in
                let items = values.map { DisplayItem(track: $0) }.map { TrackCellViewModel(inputs: TrackCellVMContract.Input(mode: .remote, track: $0, saved: true)) }.map {
                    AllTrackCellVM.track($0)
                }
                self.datas.accept(items)
            }.disposed(by: disposeBag)
        }
    }
}

enum DownloadCellVMContract {
    struct Input: InputType {
        var notSyncedTrack: BehaviorRelay<Int>
        var timeRemaining: Observable<TimeInterval>?
        var syncAllTrigger: PublishRelay<()>
    }

    struct Output: OutputType {
        var notSyncedTrack: Driver<Int>
        var timeRemaining: Driver<String>?
    }
}


final class DownloadCellViewModel: BaseCellViewModel<DownloadCellVMContract.Input, DownloadCellVMContract.Output> {

    override func transform() {
        setOutput(Output(notSyncedTrack: inputs.notSyncedTrack.asDriver(),
                         timeRemaining: inputs.timeRemaining?.map {
                            String(format:"%.1f", $0 / 60)
                         }.asDriver(onErrorJustReturn: "")))
    }
}
