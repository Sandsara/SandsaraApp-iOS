//
//  AppDelegate.swift
//  Sandsara
//
//  Created by Tín Phan on 11/7/20.
//

import UIKit
import RxSwift
import Bluejay
import Firebase

// MARK: - Bluejay initial
let bluejay = Bluejay()

// MARK: - AppDelegate, handle application state and cycle
@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    let disposeBag = DisposeBag()
    
    var startOption = StartOptions.default
    
    var lauchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    
    /// Variable to restore bluetooth from background
    var isFromBackgroundResume: Bool = false

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        AppApperance.setTheme()
        dataLayerInit()
        /// Set launch option for core bluetooth
        let centralManagerIdentifiers = launchOptions?[UIApplication.LaunchOptionsKey.bluetoothCentrals]
        self.lauchOptions = launchOptions
        SandsaraDataServices()
            .getColorPalettes(option: SandsaraDataServices()
                                .getServicesOption(for: .colorPalette))
            .subscribeNext { colors in
            print(colors)
        }.disposed(by: disposeBag)
        
        /// Init BLE Stack
        let backgroundRestoreConfig = BackgroundRestoreConfig(
            restoreIdentifier: "com.ios.sandsara.ble",
            backgroundRestorer: self,
            listenRestorer: self,
            launchOptions: lauchOptions)
        let backgroundRestoreMode = BackgroundRestoreMode.enable(backgroundRestoreConfig)
        startOption = StartOptions(
            enableBluetoothAlert: true,
            backgroundRestore: backgroundRestoreMode)
        bluejay.registerDisconnectHandler(handler: self)
        bluejay.start(mode: .new(self.startOption))
        
        /// Firebae initial
        FirebaseApp.configure()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        /// If the overlay is presentiing, we can't disconnect the board
        if (UIApplication.topViewController() is OverlaySendFileViewController) {
            isFromBackgroundResume = false
        } else {
            isFromBackgroundResume = true
            bluejay.cancelEverything()
            bluejay.disconnect(immediate: true)
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

        // observe connection
        ReachabilityManager.shared.stopMonitoring()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        ReachabilityManager.shared.stopMonitoring()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        ReachabilityManager.shared.startMonitoring()
        if isFromBackgroundResume {
            restart()
        }
    }
    
    // MARK: Reinit BLE Stack if stuff is not working correctly
    func reinitStack() {
        let backgroundRestoreConfig = BackgroundRestoreConfig(
            restoreIdentifier: "com.ios.sandsara.ble",
            backgroundRestorer: self,
            listenRestorer: self,
            launchOptions: lauchOptions)
        
        let backgroundRestoreMode = BackgroundRestoreMode.enable(backgroundRestoreConfig)
        
        startOption = StartOptions(
            enableBluetoothAlert: true,
            backgroundRestore: backgroundRestoreMode)
        bluejay.registerDisconnectHandler(handler: self)
        bluejay.start(mode: .new(self.startOption))
    }
    
    // MARK: - Reconnect again from background if the state is running
    func restart() {        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { 
            if let board = Preferences.AppDomain.connectedBoard {
                bluejay.connect(PeripheralIdentifier(uuid: board.uuid, name: board.name)) { result in
                    switch result {
                    case .success:
                        DeviceServiceImpl.shared.readSensorValues()
                    case .failure(let error):
                        print(error.localizedDescription)
                        bluejay.connect(PeripheralIdentifier(uuid: board.uuid, name: board.name)) { result in
                            switch result {
                            case .success:
                                DeviceServiceImpl.shared.readSensorValues()
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        ReachabilityManager.shared.stopMonitoring()
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: Init miniplayer bar
    func initPlayerBar() {
        let player = PlayerViewController.shared
        player.modalPresentationStyle = .fullScreen
        player.popupContentView.popupCloseButtonStyle = .none

        if UIApplication.topViewController()?.tabBarController?.popupBar.customBarViewController == nil {
            let customBar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: PlayerBarViewController.identifier) as! PlayerBarViewController
            if bluejay.isConnected {
                switch DeviceServiceImpl.shared.status.value {
                case .busy:
                    customBar.state = .busy
                case .calibrating:
                    customBar.state = .calibrating
                case .sleep:
                    customBar.state = .sleep
                default:
                    customBar.state = .connected
                }
            } else {
                customBar.state = .noConnect
            }
            UIApplication.topViewController()?.tabBarController?.popupBar.customBarViewController = customBar
        }
        UIApplication.topViewController()?.tabBarController?.popupBar.isHidden = false
        UIApplication.topViewController()?.tabBarController?.popupContentView.popupCloseButton.isHidden = true
        UIApplication.topViewController()?.tabBarController?.presentPopupBar(withContentViewController: player, openPopup: false, animated: false, completion: nil)
    }
    
    private func dataLayerInit() {
        DataLayer.shareInstance.config()
        _ = DataLayer.init()
    }
}

//MARK: - Bluetooth background restore handler
extension AppDelegate: BackgroundRestorer {
    func didRestoreConnection(
        to peripheral: PeripheralIdentifier) -> BackgroundRestoreCompletion {
        Preferences.AppDomain.connectedBoard = ConnectedPeripheralIdentifier(uuid: peripheral.uuid, name: peripheral.name)
        return .callback(checkStatus)
    }

    func didFailToRestoreConnection(
        to peripheral: PeripheralIdentifier, error: Error) -> BackgroundRestoreCompletion {
        // Opportunity to perform cleanup or error handling logic here.
        DeviceServiceImpl.shared.cleanup()
        return .continue
    }
    
    private func checkStatus() {
        DeviceServiceImpl.shared.readSensorValues()
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }
}

//MARK: - Bluetooth listen handler
extension AppDelegate: ListenRestorer {
    func didReceiveUnhandledListen(
        from peripheral: PeripheralIdentifier,
        on characteristic: CharacteristicIdentifier,
        with value: Data?) -> ListenRestoreAction {
        // Re-install or defer installing a callback to a notifying characteristic.
        return .promiseRestoration
    }
}

//MARK: - Bluetooth Disconnection handler
extension AppDelegate: DisconnectHandler {
    func didDisconnect(from peripheral: PeripheralIdentifier, with error: Error?, willReconnect autoReconnect: Bool) -> AutoReconnectMode {
        if isFromBackgroundResume {
            /// if isBackgroundResume is true, need to disable bluejay auto reconnect behavior to prevent auto connect issue
            return .change(shouldAutoReconnect: false)
        }
        return .noChange
    }
}
