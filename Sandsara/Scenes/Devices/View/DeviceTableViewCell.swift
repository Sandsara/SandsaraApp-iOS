//
//  DeviceTableViewCell.swift
//  Sandsara
//
//  Created by Tín Phan on 27/12/2020.
//

import UIKit
import Bluejay
import RxSwift
import RxCocoa

extension ScanDiscovery {
    
    /// Rssi Image base on RSSI value
    var rssiImage: UIImage? {
        switch labs(rssi) {
        case 0 ..< 23:
            return Asset._1st.image
        case 23 ..< 46:
            return Asset._2nd.image
        case 46 ..< 68:
            return Asset._3rd.image
        case 68 ..< 89:
            return Asset._4th.image
        default: return UIImage()
        }
    }
}
// MARK: Device Cell
class DeviceTableViewCell: BaseTableViewCell<DeviceCellViewModel> {
    //MARK: Outlet connections between swift file and xib/ storyboard file
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var indicatorButton: LoadingButton!

    override func awakeFromNib() {
        selectionStyle = .none
        titleLabel.font = FontFamily.OpenSans.regular.font(size: 18)
    }

    override func bindViewModel() {
        viewModel
            .outputs.device
            .driveNext { sensor in
                self.titleLabel.text = sensor.peripheralIdentifier.name
                self.indicatorButton.setImage(sensor.rssiImage, for: .normal)
        }.disposed(by: disposeBag)

        viewModel
            .inputs
            .actionTrigger.subscribeNext {
                $0 ? self.indicatorButton.showLoading(): self.indicatorButton.hideLoading()
            }.disposed(by: disposeBag)
    }

}
// MARK: Device Cell VM Contract
enum DeviceCellVMContract {
    struct Input: InputType {
        var device: ScanDiscovery
        var actionTrigger = PublishRelay<Bool>()
    }

    struct Output: OutputType {
        var device: Driver<ScanDiscovery>
    }
}

class DeviceCellViewModel: BaseCellViewModel<DeviceCellVMContract.Input, DeviceCellVMContract.Output> {
    override func transform() {
        setOutput(Output(device: Driver.just(inputs.device)))
    }
}
