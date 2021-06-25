//
//  ScanDevicesViewController.swift
//  Sandsara
//
//  Created by Tín Phan on 20/11/2020.
//

import UIKit
import Bluejay
import RxSwift
import RxCocoa
import RxDataSources



class ScanViewController: BaseVMViewController<ScanDevicesViewModel, NoInputParam> {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(DeviceTableViewCell.nib,
                               forCellReuseIdentifier: DeviceTableViewCell.identifier)
        }
    }

    @IBOutlet weak var backBtn: UIBarButtonItem!

    let viewWillAppearTrigger = PublishRelay<()>()
    let viewWillDisapearTrigger = PublishRelay<()>()
    let selectConnect = PublishRelay<Int>()

    typealias Section = SectionModel<String, DeviceCellViewModel>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    private lazy var dataSource: DataSource = self.makeDataSource()
    
    var isFromAdvanceSetting: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = L10n.chooseDevice
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ScanViewController.appDidResume),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ScanViewController.appDidBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        backBtn.rx.tap.asDriver().driveNext {
            if self.isFromAdvanceSetting {
                /// Reconnect if we didnt connect to a new board from the advance setting flow
                if let board = Preferences.AppDomain.connectedBoard {
                    if !bluejay.isConnected {
                        bluejay.connect(PeripheralIdentifier(uuid: board.uuid, name: board.name), 
                                        timeout: .seconds(20.0)) { result in
                            switch result {
                            case.success:
                                DeviceServiceImpl.shared.readSensorValues()
                            case .failure(let error):
                                print("\(error.localizedDescription)")
                            }
                        }
                    }
                }
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }.disposed(by: disposeBag)
    }

    override func setupViewModel() {
        viewModel = ScanDevicesViewModel(inputs: ScanDevicesContract.Input(viewWillAppearTrigger: viewWillAppearTrigger,
                                                                           viewWillDisappearTrigger: viewWillDisapearTrigger,
                                                                           connectionTriggerAtIndex: selectConnect))
    }

    @objc func appDidResume() {
        viewWillAppearTrigger.accept(())
    }

    @objc func appDidBackground() {
        viewWillDisapearTrigger.accept(())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bluejay.register(connectionObserver: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bluejay.unregister(connectionObserver: self)
        viewWillDisapearTrigger.accept(())
    }

    override func bindViewModel() {
        viewModel
            .outputs
            .datasources
            .map { [Section(model: "", items: $0)] }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        // MARK: Tableview selection handle
        Observable
            .zip(
                tableView.rx.itemSelected,
                tableView.rx.modelSelected(DeviceCellViewModel.self)
            ).bind { [weak self] indexPath, model in
                guard let self = self else { return }
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.navigationItem.title = L10n.connecting
                self.selectConnect.accept(indexPath.row)
            }.disposed(by: disposeBag)

        // MARK: Connection result output
        viewModel
            .outputs
            .connectionResult
            .compactMap { $0 }
            .driveNext { result in
                switch result {
                case .success:
                    debugPrint("Connection attempt is successful")
                case .failure(let error):
                    let alertVC = UIAlertController(title: "Alert", message: "Failed to connect with error: \(error.localizedDescription)", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "Try again", style: .default, handler: { _ in
                        bluejay.cancelEverything()
                        bluejay.disconnect()
                    }))
                    UIApplication.topViewController()?.present(alertVC, animated: true, completion: nil)
                }
            }.disposed(by: disposeBag)
    }

    private func makeDataSource() -> DataSource {
        return RxTableViewSectionedReloadDataSource<Section>(
            configureCell: { (_, tableView, indexPath, viewModel) -> UITableViewCell in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: DeviceTableViewCell.identifier, for: indexPath) as? DeviceTableViewCell else { return UITableViewCell()}
                cell.bind(to: viewModel)
                return cell
            })
    }
}

// MARK: Connectionn Handler
extension ScanViewController: ConnectionObserver {
    func bluetoothAvailable(_ available: Bool) {
        debugPrint("ScanViewController - Bluetooth available: \(available)")
        if available {
            viewWillAppearTrigger.accept(())
        } else {
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.reinitStack()
                viewWillAppearTrigger.accept(())
            }
        }
    }

    func connected(to peripheral: PeripheralIdentifier) {
        debugPrint("ScanViewController - Connected to: \(peripheral.description)")
        bluejay.read(from: LedStripService.ledStripSpeed) { [weak self] (result: ReadResult<String>) in
            switch result {
            case .success(let location):
                /// If the board is connected successfully, trigger a notification to go back to ConnectionGuideVC and trigger read Sandsara board data immediately
                debugPrint("Read from sensor location is successful: \(location)")
                let alertVC = UIAlertController(title: "Alert", message: "Connection attempt to: \(peripheral.name) is successful", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                    self?.dismiss(animated: true, completion: {
                        NotificationCenter.default.post(name: connectedd, object: nil)
                    })
                }))
                Preferences.AppDomain.connectedBoard = ConnectedPeripheralIdentifier(uuid: peripheral.uuid, name: peripheral.name)
                UIApplication.topViewController()?.present(alertVC, animated: true, completion: nil)
                DeviceServiceImpl.shared.readSensorValues()
            case .failure(let error):
                let alertVC = UIAlertController(title: "Alert", message: "Failed to read sensor location with error: \(error.localizedDescription)", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                    bluejay.cancelEverything()
                    bluejay.disconnect()
                }))
                UIApplication.topViewController()?.present(alertVC, animated: true, completion: nil)
                debugPrint("Failed to read sensor location with error: \(error.localizedDescription)")
            }
        }
    }
}

