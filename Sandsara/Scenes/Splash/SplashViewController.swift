//
//  SplashViewController.swift
//  Sandsara
//
//  Created by Tín Phan on 28/01/2021.
//

import UIKit
import Alamofire
import Bluejay
class SplashViewController: BaseViewController<NoInputParam> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Get all the track here so when we complete read data from the Sandsara, we always have the full data of the now playing tracks
        /// here you have to use the tracks endpoint of the data base.
        AF.request("Tracks endpoint", method: .get, parameters: ["view": "all",
                                                                                                      "sort[0][field]" : "name"], encoding: URLEncoding.default, headers: [
                                                                                                        "Authorization": "Bearer \(token)"
                                                                                                      ]).responseJSON { response in
            guard response.error == nil else {
                print(response.error!)
                return
            }
            guard let data = response.data else {
                print("No Data")
                return
            }
            do {
                let decoder = JSONDecoder()
                let info = try decoder.decode(TracksResponse.self, from: data)
                print(info)
                Preferences.PlaylistsDomain.allTracks = info.tracks.map {
                    $0.playlist
                }
                
                // Reconnection here to make sure things work correctly before the app get to home screen
                if let board = Preferences.AppDomain.connectedBoard {
                    if !bluejay.isConnected {
                        bluejay.connect(PeripheralIdentifier(uuid: board.uuid, name: board.name), 
                                        timeout: .seconds(20.0)) { result in
                            switch result {
                            case.success:
                                guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
                                let tabbarVC = self.storyboard?.instantiateViewController(withIdentifier: "tabbarVC") as! BaseTabBarViewController
                                delegate.window?.rootViewController = tabbarVC
                            case .failure(let error):
                                guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
                                let tabbarVC = self.storyboard?.instantiateViewController(withIdentifier: "tabbarVC") as! BaseTabBarViewController
                                delegate.window?.rootViewController = tabbarVC
                                print("\(error.localizedDescription)")
                                bluejay.cancelEverything()
                            }
                        }
                    } else {
                        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
                        let tabbarVC = self.storyboard?.instantiateViewController(withIdentifier: "tabbarVC") as! BaseTabBarViewController
                        delegate.window?.rootViewController = tabbarVC
                    }
                } else {
                    if bluejay.isConnected {
                        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
                        let tabbarVC = self.storyboard?.instantiateViewController(withIdentifier: "tabbarVC") as! BaseTabBarViewController
                        delegate.window?.rootViewController = tabbarVC
                        DeviceServiceImpl.shared.readSensorValues()
                    } else {
                        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
                        let tabbarVC = self.storyboard?.instantiateViewController(withIdentifier: "tabbarVC") as! BaseTabBarViewController
                        delegate.window?.rootViewController = tabbarVC
                    }
                }
            } catch {
                print(error)
            }
          }
    }
}
