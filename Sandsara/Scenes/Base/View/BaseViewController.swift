//
//  BaseViewController.swift
//  Sandsara
//
//  Created by Tín Phan on 11/7/20.
//

import UIKit
import RxSwift
import RxCocoa
import NVActivityIndicatorView
import Reachability
import SVProgressHUD

// MARK: - Input & Ouput for View
protocol InputParamView {}
protocol OutputParamView {}

struct NoInputParam: InputParamView {}
struct NoOutputParam: OutputParamView {}

class BaseViewController<Input: InputParamView>: UIViewController {

    let once = Once()
    var _disposeBag = DisposeBag()
    var disposeBag: DisposeBag! {
        return _disposeBag
    }

    lazy var loadingActivity: NVActivityIndicatorView! = {
        let indicatorX = (view.frame.width - 50)/2
        let indicatorY = (view.frame.height - 50)/2
        let centerRect = CGRect(x: indicatorX,
                                y: indicatorY,
                                width: 50,
                                height: 50)
        var loadingActivity = NVActivityIndicatorView(frame: centerRect,
                                                      type: .ballClipRotatePulse,
                                                      color: Asset.primary.color,
                                                      padding: nil)
        view.addSubview(loadingActivity)
        view.bringSubviewToFront(loadingActivity)
        return loadingActivity
    }()

    var isPlaySingle: Bool {
        get {
            return _isSingle
        } set(newValue) {
            _isSingle = newValue
        }
    }

    private var _isSingle = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Asset.background.color
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ReachabilityManager.shared.addListener(listener: self)
        
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        }
    }
    
    @objc func willResignActive(_ notification: Notification) {
        // code to execute
        if ((UIApplication.topViewController()?.tabBarController?.popupBar.customBarViewController as? PlayerBarViewController)?.state == .busy || (UIApplication.topViewController()?.tabBarController?.popupBar.customBarViewController as? PlayerBarViewController)?.state == .noConnect) {
            // start to restore state there 
            (UIApplication.shared.delegate as! AppDelegate).isFromBackgroundResume = false
        } else {
            (UIApplication.shared.delegate as! AppDelegate).isFromBackgroundResume = true
            bluejay.disconnect()
        }
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }


    /// Setup layout navigation bar item
    private func initBarButtonItem(isRight: Bool, image: UIImage?) -> UIBarButtonItem {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.backgroundColor = .clear
        var selector = #selector(lefttButtonClick)
        if isRight {
            selector = #selector(BaseViewController.rightButtonClick)
        }
        button.addTarget(self, action: selector,
                         for: .touchUpInside)
        button.setImage(image, for: .normal)

        return UIBarButtonItem(customView: button)
    }

    func layoutNavigationBarLeft(image: UIImage?) {
        let leftBarButtonItem = initBarButtonItem(isRight: false, image: image)
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }

    func layoutNavigationBarRight(image: UIImage?) {
        let rightBarButtonItem = initBarButtonItem(isRight: true, image: image)
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    @objc func rightButtonClick() {}

    @objc func lefttButtonClick() {}

    func triggerAPIAgain() {}

    private func setHUDStyle() {
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setMaximumDismissTimeInterval(0.8)
        SVProgressHUD.setBackgroundColor(Asset.primary.color)
        SVProgressHUD.setForegroundColor(Asset.background.color)
    }
    
    
    /// Show HUD Error
    /// - Parameter message: error message
    func showErrorHUD(message: String) {
        setHUDStyle()
        SVProgressHUD.showError(withStatus: message)
    }

    /// Show HUD Success
    /// - Parameter message: success message
    func showSuccessHUD(message: String) {
        setHUDStyle()
        SVProgressHUD.showSuccess(withStatus: message)
    }
}

extension BaseViewController: NetworkStatusListener {
    func networkStatusDidChange(status: Reachability.Connection) {
        if status == .none {
            self.triggerAPIAgain()
        }
    }
}


