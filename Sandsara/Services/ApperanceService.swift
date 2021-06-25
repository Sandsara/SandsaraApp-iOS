//
//  ApperanceService.swift
//  Sandsara
//
//  Created by Tín Phan on 15/11/2020.
//

import UIKit

// MARK: App Apperance Handler for nav bar and tab bar
struct AppApperance {
    
    
    /// Set theme function
    static func setTheme() {
        setNavApperrance()
        setTabBarAppearance()
    }
    
    /// Set tabbar appearance
    private static func setTabBarAppearance() {
        if #available(iOS 13, *) {
            let appearance = UITabBarAppearance()

            appearance.backgroundColor = Asset.background.color

            appearance.stackedLayoutAppearance.normal.iconColor = Asset.secondary.color
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Asset.secondary.color]
            appearance.stackedLayoutAppearance.normal.badgeBackgroundColor = Asset.secondary.color

            appearance.stackedLayoutAppearance.selected.iconColor = Asset.primary.color
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Asset.primary.color]

            appearance.stackedLayoutAppearance.disabled.iconColor = Asset.secondary.color
            appearance.stackedLayoutAppearance.disabled.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Asset.secondary.color]
            appearance.stackedLayoutAppearance.disabled.badgeBackgroundColor = Asset.secondary.color

            UITabBar.appearance().standardAppearance = appearance
        } else {
            UITabBarItem.appearance()
                .setTitleTextAttributes(
                    [NSAttributedString.Key.foregroundColor: Asset.primary.color], for: .selected)
            UITabBarItem.appearance()
                .setTitleTextAttributes(
                    [NSAttributedString.Key.foregroundColor: Asset.secondary.color], for: [.normal, .disabled])
            UITabBar.appearance().tintColor = Asset.primary.color
            UITabBar.appearance().backgroundColor =  Asset.background.color
            UITabBar.appearance().unselectedItemTintColor = Asset.secondary.color
        }
    }
    
    /// Set navbar appearance
    private static func setNavApperrance() {
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -1000.0, vertical: 0.0), for: .default)
        UINavigationBar.appearance().tintColor = Asset.primary.color
        UINavigationBar.appearance().barTintColor = Asset.primary.color
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes
            .updateValue(Asset.primary.color, forKey: NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue))
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().prefersLargeTitles = false
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            //   navBarAppearance.configureWithDefaultBackground()
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: Asset.primary.color]
            navBarAppearance.titleTextAttributes = [.foregroundColor: Asset.primary.color]
            navBarAppearance.backgroundColor = Asset.background.color

            UINavigationBar.appearance().standardAppearance = navBarAppearance
            UINavigationBar.appearance().compactAppearance = navBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        } else {
            // Fallback on earlier versions
            UINavigationBar.appearance().backgroundColor = Asset.background.color
            UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: Asset.primary.color]
            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: Asset.primary.color]
        }
    }
}
