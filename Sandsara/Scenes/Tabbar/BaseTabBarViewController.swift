//
//  BaseTabBarViewController.swift
//  Sandsara
//
//  Created by Tín Phan on 28/12/2020.
//

import UIKit

let reloadTab = Notification.Name(rawValue: "reloadTab")
let reloadPlaylist = Notification.Name(rawValue: "reloadPlaylist")

// MARK: Custom tabbar controller
class BaseTabBarViewController: UITabBarController {

    private let once = Once()
    private var browseVC: BrowseViewController?
    private var libVC: LibraryViewController?
    private var settingVC: SettingsViewController?
    private var connectVC: ConnectionGuideViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        defer {
            setupControllers(isConnected: true)
        }
        browseVC = storyboard?.instantiateViewController(withIdentifier: BrowseViewController.identifier) as? BrowseViewController
        libVC = storyboard?.instantiateViewController(withIdentifier: LibraryViewController.identifier) as? LibraryViewController
        settingVC = storyboard?.instantiateViewController(withIdentifier: SettingsViewController.identifier) as? SettingsViewController
        connectVC = storyboard?.instantiateViewController(withIdentifier: ConnectionGuideViewController.identifier) as? ConnectionGuideViewController
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    @objc func updateControllers() {
        setupControllers(isConnected: bluejay.isConnected)
    }

    private func setupControllers(isConnected: Bool) {
        let firstNavVC = UINavigationController(rootViewController: browseVC!)
        firstNavVC.tabBarItem = UITabBarItem(title: "Browse", image: Asset.search.image, selectedImage: Asset.search.image)
        let secondNavVC = UINavigationController(rootViewController: libVC!)
        secondNavVC.tabBarItem = UITabBarItem(title: "Library", image: Asset.library.image, selectedImage: Asset.library.image)
        let thirdNavVC = UINavigationController(rootViewController: settingVC!)
        thirdNavVC.tabBarItem = UITabBarItem(title: "Settings", image: Asset.settings.image, selectedImage: Asset.settings.image)

        viewControllers = [firstNavVC,
                           secondNavVC,
                           thirdNavVC]
        tabBarController?.selectedIndex = 0
        AppApperance.setTheme()
    }
}
