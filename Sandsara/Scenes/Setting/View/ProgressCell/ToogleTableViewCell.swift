//
//  ToogleTableViewCell.swift
//  Sandsara
//
//  Created by Tín Phan on 05/12/2020.
//

import UIKit
import RxSwift
import RxCocoa

class ToogleTableViewCell: BaseTableViewCell<ToogleCellViewModel> {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet private weak var toogleSwitch: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func bindViewModel() {
        viewModel.outputs.toogle.drive(toogleSwitch.rx.isOn).disposed(by: disposeBag)
        viewModel.outputs.title.drive(titleLabel.rx.text).disposed(by: disposeBag)

        // MARK: Toogle switch handle logic
        toogleSwitch
            .rx.isOn
            .changed
           // .skip(1)
            .debounce(.milliseconds(200), scheduler: MainScheduler.asyncInstance)
            .distinctUntilChanged()
            .asObservable()
            .subscribeNext { [weak self] value in
                guard let self = self else { return }
                let viewModel = self.viewModel
                switch viewModel?.inputs.type {
                case .sleep:
                    if value {
                        bluejay.write(to: DeviceService.sleep, value: "1") { result in
                            switch result {
                            case .success:
                                debugPrint("Sleep Success")
                            //DeviceServiceImpl.shared.readDeviceStatus()
                            case .failure(let error):
                                print(error.localizedDescription)
                                if error.localizedDescription == "" {
                                    //  DeviceServiceImpl.shared.readDeviceStatus()
                                }
                            }
                        }
                    } else {
                        bluejay.write(to: DeviceService.play, value: "1") { result in
                            switch result {
                            case .success:
                                debugPrint("Resume Success")
                            //DeviceServiceImpl.shared.readDeviceStatus()
                            case .failure(let error):
                                print(error.localizedDescription)
                                if error.localizedDescription == "" {
                                    //  DeviceServiceImpl.shared.readDeviceStatus()
                                }
                            }
                        }
                    }
                case .rotate:
                    DeviceServiceImpl.shared.updateCycleMode(mode: value ? "0" : "1")
                default:
                    break
                }
        }.disposed(by: disposeBag)
    }
}
