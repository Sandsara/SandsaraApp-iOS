//
//  AdvanceSettingViewModel.swift
//  Sandsara
//
//  Created by Tín Phan on 28/11/2020.
//

import RxSwift
import RxCocoa

enum AdvanceSettingViewModelContract {
    struct Input: InputType {
        let viewWillAppearTrigger: PublishRelay<()>
    }

    struct Output: OutputType {
        let datasources: Driver<[SettingItemCellType]>
    }
}

final class AdvanceSettingViewModel: BaseViewModel<AdvanceSettingViewModelContract.Input, AdvanceSettingViewModelContract.Output> {
    let datas = BehaviorRelay<[SettingItemCellType]>(value: [])
    override func transform() {
        inputs.viewWillAppearTrigger.subscribeNext { [weak self] in
            guard let self = self else { return }
            // Placeholder data
            let values = self.buildCellVM()
            self.datas.accept(values)
            SandsaraDataServices().getFirmwares(option: SandsaraDataServices()
                                                    .getServicesOption(for: .firmware))
                .subscribeNext { [weak self] firmwares in
                guard let self = self else { return }
                for firmware in firmwares {
                    /// Compare logic here, if the API's firmware is greater than current Sandsara firmware version, show the download button for user to update firmware
                    if firmware.version > DeviceServiceImpl.shared.firmwareVersion.value {
                        Preferences.AppDomain.firmwareVersion = firmware.version
                        var values = self.buildCellVM()
                        values.insert(.updateFirmware(DownloadFirmwareViewModel(inputs: DownloadFirmwareVMContract.Input(latestVersion: firmware.version, file: firmware.file?.first))), at: 3)
                        self.datas.accept(values)
                        break
                    }
                }
            }.disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)

        setOutput(Output(datasources: datas.asDriver()))
    }

    
    /// Build Advance Setting Data
    /// - Returns: Array of SettingItemCellType
    private func buildCellVM() -> [SettingItemCellType] {
        var datas = [SettingItemCellType]()
        datas.append(.menu(MenuCellViewModel(inputs: MenuCellVMContract.Input(type: .deviceName(DeviceServiceImpl.shared.deviceName.value.isEmpty ? "N/A" : DeviceServiceImpl.shared.deviceName.value), color: Asset.secondary.color))))
        datas.append(.menu(MenuCellViewModel(inputs: MenuCellVMContract.Input(type: .changeName))))
        datas.append(.menu(MenuCellViewModel(inputs: MenuCellVMContract.Input(type: .firmwareVersion(DeviceServiceImpl.shared.firmwareVersion.value.isEmpty ? "N/A" : DeviceServiceImpl.shared.firmwareVersion.value ), color: Asset.secondary.color))))
        datas.append(.menu(MenuCellViewModel(inputs: MenuCellVMContract.Input(type: .factoryReset))))
        datas.append(.menu(MenuCellViewModel(inputs: MenuCellVMContract.Input(type: .connectNew))))
        return datas
    }
}


