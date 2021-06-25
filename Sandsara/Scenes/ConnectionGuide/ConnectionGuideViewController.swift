//
//  ConnectionGuideViewController.swift
//  Sandsara
//
//  Created by Tín Phan on 28/12/2020.
//

import UIKit

let connectedd = Notification.Name(rawValue: "connectedSuccess")

class ConnectionGuideViewController: BaseViewController<NoInputParam> {

    // MARK: - Outlet connection
    @IBOutlet weak var connectionHeaderLabel: UILabel!
    @IBOutlet weak var connectionDescLabel: UILabel!
    @IBOutlet weak var connectNowBtn: UIButton!
    @IBOutlet weak var aligmentConstraint: NSLayoutConstraint!
    
    var isFromAdvanceSetting: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(connectedSuccess), name: connectedd, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: connectedd, object: nil)
    }
    
    
    /// Observed action after the connection is completed successfully from ScanDeviceViewController or AdvanceSettingViewController
    @objc func connectedSuccess() {
        if isFromAdvanceSetting {
            NotificationCenter.default.post(name: reloadTab, object: nil)
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: reloadTab, object: nil)
            })
        }
    }

    
    /// Setup UI Stuff like text, button action
    private func setupUI() {
        connectionHeaderLabel.text = L10n.connectToSandsara
        connectionDescLabel.text = L10n.connectDesc
        connectNowBtn.setTitle(L10n.connectNow, for: .normal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Asset.close.image, style: .done, target: self, action: #selector(dismissVC))
        DispatchQueue.main.async {
            self.aligmentConstraint.constant = self.isFromAdvanceSetting ? 80 : 213
        }
    }
    
    
    /// UI Binding action
    private func bindings() {
        connectNowBtn
            .rx.tap.asDriver()
            .driveNext {
            self.goToScanDevices()
        }.disposed(by: disposeBag)
    }
    
    
    /// Open Scan Device Screen
    private func goToScanDevices() {
        func openVC() {
            let scanVC: ScanViewController = self.storyboard?.instantiateViewController(withIdentifier: ScanViewController.identifier) as! ScanViewController
            let navVC = UINavigationController(rootViewController: scanVC)
            self.present(navVC, animated: true, completion: nil)
        }
        if isFromAdvanceSetting {
            bluejay.cancelEverything()
            bluejay.disconnect(immediate: true) { result in
                switch result {
                case .disconnected:
                    openVC()
                case .failure(let error):
                    bluejay.cancelEverything()
                    openVC()
                }
            }
        } else {
            openVC()
        }
    }

    
    /// Dismiss function
    @objc func dismissVC() {
        if !isFromAdvanceSetting {
            self.dismiss(animated: true)
            return
        }
        self.navigationController?.popViewController(animated: true)
    }
}
