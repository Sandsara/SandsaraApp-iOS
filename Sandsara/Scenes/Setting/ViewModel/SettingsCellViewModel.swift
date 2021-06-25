//
//  SettingsCellViewModel.swift
//  Sandsara
//
//  Created by Tín Phan on 11/11/20.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Bluejay

@available(*, deprecated, message: "Please use color model from Airtable")
enum PredifinedColor: Int, CaseIterable {
    case one
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    
    var colors: [UIColor] {
        var colorStrings = [String]()
        switch self {
        case .one:
            colorStrings = ["FB7657", "FD5962", "E95EBB", "6B3EF3", "F35EC5", "FD5962", "FB7657"]
        case .two:
            colorStrings = ["FEF0D6", "FFAFB2", "BEE9E9", "FEF0D6"]
        case .three:
            colorStrings = ["14F7F7", "FFFFFF", "D00040", "E700D5", "14F7F7"]
        case .four:
            colorStrings = ["FF3306", "FFFFFF", "FF0653", "FF3306"]
        case .five:
            colorStrings = ["86DBD8", "FC4C61", "FEE6E6", "FF6A5A", "FFC8C5", "FDB57B", "86DBD8"]
        case .six:
            colorStrings = ["06A4AF", "D8EBCB", "06A4AF"]
        case .seven:
            colorStrings = ["BCE9FE", "FDDDEA", "FFFFFF", "BCE9FE"]
        case .eight:
            colorStrings = ["D6F2E6", "004D7E", "D6F2E6"]
        }
        return colorStrings.map {
            UIColor(hexString: "#\($0)")
        }
    }
    
    var posistion: [CGFloat] {
        switch self {
        case .one:
            return [0, 42, 85, 127, 170, 212, 255]
        case .two:
            return [0, 85, 170, 255]
        case .three:
            return [0, 64, 127, 191, 255]
        case .four:
            return [0, 106, 212, 255]
        case .five:
            return [0, 42, 85, 127, 170, 212, 255]
        case .six:
            return [0, 127, 255]
        case .seven:
            return [0, 85, 170, 255]
        case .eight:
            return [0, 127, 255]
        }
    }
}

// MARK: user static color mode
enum StaticMode: Int {
    case colorTemp
    case customColor
}

// MARK: user lighting mode (cycle of colors or single color)
enum LightMode: Int {
    case cycle = 0
    case staticMode
}

// MARK: Setting Item Cell Type
enum SettingItemCellType {
    case speed(ProgressCellViewModel)
    case brightness(ProgressCellViewModel)
    case lightMode(LightModeCellViewModel)
    case lightCycleSpeed(ProgressCellViewModel)
    case menu(MenuCellViewModel)
    case toogle(ToogleCellViewModel)
    case updateFirmware(DownloadFirmwareViewModel)
}

// MARK: Setting Item Type
enum SettingItemType {
    case speed
    case brightness
    case lightMode
    case lightCycleSpeed
    case advanced
    case visitSandsara
    case help
    case firmwareUpdate
    case changeName
    case factoryReset
    case deviceName(String)
    case firmwareVersion(String)
    case flipMode
    case sleep
    case restart
    case connectNew
    case rotate
    
    
    /// Title of setting item
    var title: String {
        switch self {
        case .speed:
            return L10n.speed
        case .brightness:
            return L10n.brightness
        case .lightMode:
            return L10n.lightmode
        case .lightCycleSpeed:
            return L10n.lightCycleSpeed
        case .advanced:
            return L10n.advanceSetting
        case .visitSandsara:
            return L10n.website
        case .help:
            return L10n.help
        case .firmwareUpdate:
            return L10n.updateFirmware
        case .changeName: return L10n.changeName
        case .factoryReset: return L10n.factoryReset
        case .deviceName(let name):
            return L10n.deviceName(name)
        case .firmwareVersion(let version):
            return L10n.firmwareVersion(version)
        case .sleep:
            return L10n.sleep
        case .restart:
            return L10n.restart
        case .flipMode:
            return L10n.flipMode
        case .connectNew:
            return L10n.connectNew
        case .rotate:
            return L10n.rotate
        }
    }
    
    /// Min and Max value of Slider range
    var sliderValue: (Float, Float) {
        switch self {
        case .lightCycleSpeed:
            return (1, 100)
        case .speed:
            return (1, 10)
        case .brightness:
            return (0, 100)
        default:
            return (0, 0)
        }
    }
    
    /// Slider ranges
    var ranges: [Float] {
        switch self {
        case .lightCycleSpeed:
            return [Int](1...100).map {
                Float($0)
            }
        case .speed:
            return [Int](1...10).map {
                Float($0)
            }
        case .brightness:
            return [Int](0...100).map {
                Float($0)
            }
        default:
            return []
        }
    }
    
    /// Characteristic identifer for slider item
    var progressCharacteristic: CharacteristicIdentifier? {
        switch self {
        case .speed:
            return DeviceService.speed
        case .lightCycleSpeed:
            return LedStripService.ledStripSpeed
        case .brightness:
            return LedStripService.brightness
        default:
            return nil
        }
    }
    
    /// Characteristic identifer for toogle item
    var toogleCharacteristic: CharacteristicIdentifier? {
        switch self {
        case .sleep:
            return DeviceService.sleep
        case .restart:
            return DeviceService.restart
        case .factoryReset:
            return DeviceService.factoryReset
        case .flipMode:
            return LedStripService.ledStripDirection
        case .rotate:
            return LedStripService.ledStripCycleEnable
        default:
            return nil
        }
    }
}

/// Compare method
extension SettingItemType: Equatable {
    static func ==(lhs: SettingItemType, rhs: SettingItemType) -> Bool {
        switch (lhs, rhs) {
        case let (.deviceName(name1), .deviceName(name2)):
            return name1 == name2
        case let (.firmwareVersion(version1), .firmwareVersion(version2)):
            return version1 == version2
        default:
            return true
        }
    }
}

extension SettingItemCellType: Equatable {
    static func == (lhs: SettingItemCellType, rhs: SettingItemCellType) -> Bool {
        return false
    }
}

protocol SettingSendCommandable {
    func sendCommand(command: String)
}


enum ProgressCellVMContract {
    struct Input: InputType {
        let type: SettingItemType
        let progress: BehaviorRelay<Float>
    }
    
    struct Output: OutputType {
        let title: Driver<String>
        let progress: Driver<Float>
    }
}

class ProgressCellViewModel: BaseCellViewModel<ProgressCellVMContract.Input,
                                               ProgressCellVMContract.Output>, SettingSendCommandable {
    override func transform() {
        inputs
            .progress
            .skip(1)
            .distinctUntilChanged()
            .subscribeNext { value in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    print("Slider Value: \(value) ")
                    let intValue = Int(value)
                    self.sendCommand(command: "\(intValue)")
                }
                
            }.disposed(by: disposeBag)
        
        setOutput(Output(title: Driver.just(inputs.type.title),
                         progress: inputs.progress.asDriver()))
    }
    
    func sendCommand(command: String) {
        guard let character = inputs.type.progressCharacteristic else { return }
        DispatchQueue.main.async {
            bluejay.write(to: character, value: command) { result in
                switch result {
                case .success:
                    debugPrint("Write to sensor location is successful.\(result)")
                case .failure(let error):
                    debugPrint("Failed to write sensor location with error: \(error.localizedDescription)")
                }
            }
        }
    }
}

enum MenuCellVMContract {
    struct Input: InputType {
        let type: SettingItemType
        var color: UIColor = Asset.primary.color
    }
    
    struct Output: OutputType {
        let title: Driver<String>
    }
}

class MenuCellViewModel: BaseCellViewModel<MenuCellVMContract.Input,
                                           MenuCellVMContract.Output>, SettingSendCommandable {
    override func transform() {
        setOutput(Output(title: Driver.just(inputs.type.title)))
    }
    
    func sendCommand(command: String) {
        switch inputs.type {
        case .factoryReset:
            DeviceServiceImpl.shared.factoryReset()
        default:
            break
        }
    }
}


enum PresetCellVMContract {
    struct Input: InputType {
        let color: ColorModel
    }
    
    struct Output: OutputType {
        let color: Driver<ColorModel>
    }
}

class PresetCellViewModel: BaseCellViewModel<PresetCellVMContract.Input,
                                             PresetCellVMContract.Output> {
    override func transform() {
        setOutput(Output(color: Driver.just(inputs.color)))
    }
}


enum LightModeVMContract {
    struct Input: InputType {
        let type: SettingItemType
        let segmentsSelection: BehaviorRelay<LightMode>
        let flipDirection: BehaviorRelay<Bool>
        let rotateToogle: BehaviorRelay<Bool>
    }
    
    struct Output: OutputType {
        let segmentsSelection: Driver<LightMode>
        let title: Driver<String>
        let datas: Driver<[PresetCellViewModel]>
        let flipDirection: Driver<Bool>
        let rotateToogle: Driver<Bool>
        let preselectedColor: Driver<ColorModel?>
    }
}

class LightModeCellViewModel: BaseCellViewModel<LightModeVMContract.Input,
                                                LightModeVMContract.Output>, SettingSendCommandable {
    private let colors: [PredifinedColor] = PredifinedColor.allCases
    override func transform() {
        inputs
            .flipDirection
          //  .skip(1)
            .subscribeNext { value in
            }.disposed(by: disposeBag)
        
        inputs
            .rotateToogle
         //   .skip(1)
            .subscribeNext { value in
            }.disposed(by: disposeBag)
        
        let images = Preferences.AppDomain.colors?.map {
            PresetCellViewModel(inputs: PresetCellVMContract.Input(color: $0))
        }.compactMap { $0 }
        
        setOutput(Output(segmentsSelection: inputs.segmentsSelection.asDriver(),
                         title: Driver.just(inputs.type.title),
                         datas: Driver.just(images ?? []),
                         flipDirection: inputs.flipDirection.asDriver(),
                         rotateToogle: inputs.rotateToogle.asDriver(),
                         preselectedColor: DeviceServiceImpl.shared.runningColor.asDriver()))
    }
    
    func sendLightSpeed(value: Float) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            bluejay.write(to: LedStripService.ledStripSpeed, value: "\(Int(value))") { result in
                switch result {
                case .success:
                    debugPrint("Write to sensor location is successful.\(result)")
                    DeviceServiceImpl.shared.ledSpeed.accept(value)
                case .failure(let error):
                    debugPrint("Failed to write sensor location with error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    func sendCommand(command: String) {
        DispatchQueue.main.async {
            bluejay.write(to: LedStripService.ledStripDirection, value: command) { result in
                switch result {
                case .success:
                    debugPrint("Write to sensor location is successful.\(result), \(LedStripService.ledStripDirection.service)")
                case .failure(let error):
                    debugPrint("Failed to write sensor location with error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func sendRotateCommand(command: String) {
        DispatchQueue.main.async {
            bluejay.write(to: LedStripService.ledStripCycleEnable, value: command) { result in
                switch result {
                case .success:
                    debugPrint("Write to sensor location is successful.\(result), \(LedStripService.ledStripCycleEnable.service)")
                case .failure(let error):
                    debugPrint("Failed to write sensor location with error: \(error.localizedDescription)")
                }
            }
        }
    }
}

enum ToogleCellVMContract {
    struct Input: InputType {
        let type: SettingItemType
        let toogle: BehaviorRelay<Bool>
    }
    
    struct Output: OutputType {
        let title: Driver<String>
        let toogle: Driver<Bool>
    }
}

class ToogleCellViewModel: BaseCellViewModel<ToogleCellVMContract.Input,
                                             ToogleCellVMContract.Output>, SettingSendCommandable {
    override func transform() {
        // Skip initial value
        inputs
            .toogle
            .subscribeNext { value in
            }.disposed(by: disposeBag)
        
        setOutput(Output(title: Driver.just(inputs.type.title),
                         toogle: inputs.toogle.asDriver()))
    }
    
    func sendCommand(command: String) {
    }
}
