//
//  ScanDevicesViewModel.swift
//  Sandsara
//
//  Created by Tín Phan on 27/12/2020.
//

import Foundation
import RxCocoa
import RxSwift
import Bluejay

enum ScanDevicesContract {
    struct Input: InputType {
        let viewWillAppearTrigger: PublishRelay<()>
        let viewWillDisappearTrigger: PublishRelay<()>
        let connectionTriggerAtIndex: PublishRelay<Int>
    }

    struct Output: OutputType {
        let datasources: Driver<[DeviceCellViewModel]>
        let connectionResult: Driver<ConnectionResult?>
    }
}

final class ScanDevicesViewModel: BaseViewModel<ScanDevicesContract.Input, ScanDevicesContract.Output> {
    var datas = BehaviorRelay<[DeviceCellViewModel]>(value: [])
    var connectionResult = BehaviorRelay<ConnectionResult?>(value: nil)

    override func transform() {
        inputs.viewWillAppearTrigger
            .subscribeNext { [weak self] in
                /// if bluejay is scanning, need to stop immediately then start a new scanning session
                if bluejay.isScanning {
                    self?.stopScanning()
                }
                self?.scanning()
        }.disposed(by: disposeBag)

        inputs.viewWillDisappearTrigger
            .subscribeNext { [weak self] in
                self?.stopScanning()
        }.disposed(by: disposeBag)

        inputs.connectionTriggerAtIndex
            .subscribeNext { index in
            let newDatas = self.datas.value
            for i in 0 ..< newDatas.count where i != index {
                newDatas[i].inputs.actionTrigger.accept(false)
            }
            newDatas[index].inputs.actionTrigger.accept(true)
            self.datas.accept(newDatas)
            self.pairing(identifier: newDatas[index]
                            .inputs.device.peripheralIdentifier)
        }.disposed(by: disposeBag)

        setOutput(Output(datasources: datas.asDriver(),
                         connectionResult: connectionResult
                            .asDriver(onErrorJustReturn: nil)))
    }

    //MARK: Scan function
    private func scanning() {
        bluejay.scan(
            duration: 30,
            allowDuplicates: true,
            throttleRSSIDelta: 10,
            serviceIdentifiers: nil,
            discovery: { [weak self] _, discoveries -> ScanAction in
                guard let self = self else {
                    return .stop
                }
                self.datas.accept(discoveries.map {
                    DeviceCellViewModel(inputs: DeviceCellVMContract.Input(device: $0))
                })
                return .continue
            },
            expired: { [weak self] lostDiscovery, discoveries -> ScanAction in
                guard let self = self else {
                    return .stop
                }
                self.datas.accept(discoveries.map {
                    DeviceCellViewModel(inputs: DeviceCellVMContract.Input(device: $0))
                })
                return .continue
            },
            stopped: { _, error in
                if let error = error as? BluejayError {
                    debugPrint("Scan stopped with error: \(error.localizedDescription)")
                } else {
                    debugPrint("Scan stopped without error")
                }
            })
    }

    // MARK: Pairing function
    
    /// Pairing function
    /// - Parameter identifier: the selected BLE identifier
    private func pairing(identifier: PeripheralIdentifier) {
        bluejay
            .connect(identifier,
                     timeout: .seconds(15)) { result in
            self.connectionResult.accept(result)
        }
    }

    private func stopScanning() {
        if bluejay.isScanning {
            bluejay.stopScanning()
        }
    }
}
