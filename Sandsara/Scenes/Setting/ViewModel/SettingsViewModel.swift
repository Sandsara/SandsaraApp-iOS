//
//  SettingsViewModel.swift
//  Sandsara
//
//  Created by Tín Phan on 11/11/20.
//

import UIKit
import RxSwift
import RxCocoa


enum SettingViewModelContract {
    struct Input: InputType {
        let viewWillAppearTrigger: PublishRelay<()>
        let lightMode: BehaviorRelay<LightMode>
    }

    struct Output: OutputType {
        let datasources: Driver<[SettingItemCellType]>
    }
}

final class SettingViewModel: BaseViewModel<SettingViewModelContract.Input, SettingViewModelContract.Output> {

    var status = BehaviorRelay<SandsaraStatus?>(value: nil)

    var sleepMode = BehaviorRelay<Bool>(value: false)
    
    let datas = BehaviorRelay<[SettingItemCellType]>(value: [])

    override func transform() {
        // MARK: Build data function from SettingViewController
        inputs.viewWillAppearTrigger.subscribeNext { [weak self] in
            guard let self = self else { return }
            self.datas.accept(self.buildCellVM())
        }.disposed(by: disposeBag)

        // MARK: After the data was completed setup, the ViewController will automatically update the Views by the data came from SettingViewModel
        setOutput(Output(datasources: datas.asDriver()))
    }

    private func buildCellVM() -> [SettingItemCellType] {
        var datas = [SettingItemCellType]()
        /// Append Ball Speed Cell
        datas.append(.speed(ProgressCellViewModel(inputs: ProgressCellVMContract.Input(type: .speed,
                                                                                       progress: DeviceServiceImpl.shared.ballSpeed))))
        /// Append Brightness Cell
        datas.append(.brightness(ProgressCellViewModel(inputs: ProgressCellVMContract.Input(type: .brightness,
                                                                                            progress: DeviceServiceImpl.shared.brightness))))
        /// Append Light Mode cell
        datas.append(.lightMode(LightModeCellViewModel(inputs: LightModeVMContract.Input(type: .lightMode, segmentsSelection: inputs.lightMode,
                                                                                         flipDirection: DeviceServiceImpl.shared.flipDirection,
                                                                                         rotateToogle: DeviceServiceImpl.shared.cycleMode))))
        /// Append Sleep Cell
        datas.append(.toogle(ToogleCellViewModel(inputs: ToogleCellVMContract.Input(type: .sleep, toogle: DeviceServiceImpl.shared.sleepStatus))))
        return datas
    }
}

