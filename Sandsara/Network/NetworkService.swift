//
//  NetworkService.swift
//  Sandsara
//
//  Created by Tín Phan on 22/11/2020.
//

import Reachability
import RxReachability
import RxSwift
import RxCocoa
import Alamofire
import UIKit
protocol NetworkStatusListener: class {
    func networkStatusDidChange(status: Reachability.Connection)
}

class ReachabilityManager: NSObject {
    static  let shared = ReachabilityManager()


    var isNetworkAvailable : Bool {
        return reachabilityStatus != .none
    }

    var reachabilityStatus: Reachability.Connection = .none
    // 5. Reachability instance for Network status monitoring
    let reachability = Reachability()!

    var listeners = [NetworkStatusListener]()

    @objc func reachabilityChanged(_ notification: Notification) {
        let reachability = notification.object as! Reachability
        switch reachability.connection {
        case .none:
            debugPrint("Network became unreachable")
        case .wifi:
            debugPrint("Network reachable through WiFi")
        case .cellular:
            debugPrint("Network reachable through Cellular Data")
        }
        self.reachabilityStatus = reachability.connection
        for listener in listeners {
            listener.networkStatusDidChange(status: reachability.connection)
        }
    }

    func startMonitoring() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: .reachabilityChanged, object: reachability)
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        }
        reachability.whenUnreachable = { _ in
            print("Not reachable")
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }


    func stopMonitoring() {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                  name: .reachabilityChanged,
                                                  object: reachability)
    }


    func addListener(listener: NetworkStatusListener){
        listeners.append(listener)
    }

    /// Removes a listener from listeners array
    ///
    /// - parameter delegate: the listener which is to be removed
    func removeListener(listener: NetworkStatusListener){
        listeners = listeners.filter{ $0 !== listener}
    }

}

protocol NetworkingService {
    var isConnected: Bool { get }
    var connected: BehaviorRelay<Bool> { get }
    func startCheckingNetworkConnection()
    func stopCheckingNetworkConnection()
}

final class NetworkingServiceImpl: NetworkingService {
    private let sharedInstance = NetworkReachabilityManager()!
    private let reachability: Reachability
    private let disposeBag = DisposeBag()

    var connected =  BehaviorRelay<Bool>(value: true)

    init(reachability: Reachability = Reachability()!) {
        self.reachability = reachability
        self.reachability
            .rx
            .isReachable
            .subscribeNext { [weak self] isConnected in
                guard let self = self else { return }
                self.connected.accept(isConnected)
            }.disposed(by: disposeBag)
    }

    var isConnected: Bool {
        return self.sharedInstance.isReachable
    }

    func startCheckingNetworkConnection() {
        try? reachability.startNotifier()
    }

    func stopCheckingNetworkConnection() {
        reachability.stopNotifier()
    }
}
