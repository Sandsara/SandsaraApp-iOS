//
//  UIViewController.swift
//  Sandsara
//
//  Created by Tín Phan on 11/8/20.
//

import UIKit

class Once {
    var already: Bool = false

    func run(block: () -> Void) {
        guard !already else { return }

        block()
        already = true
    }
}

extension UIViewController {
    /// Call this once to dismiss open keyboards by tapping anywhere in the view controller
    func setupHideKeyboardOnTap() {
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        self.navigationController?.navigationBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    @objc func dismissKeyboard () {
        view.endEditing(true)
    }
}

extension UIViewController {
    static var identifier: String {
        get {
            return String(describing: self)
        }
    }
    
    
    /// Configure navigation bar
    /// - Parameters:
    ///   - largeTitleColor: Color of title
    ///   - backgoundColor: Color of navigation bar background
    ///   - tintColor: Color of navigation bar button
    ///   - title: title of navigation bar
    ///   - preferredLargeTitle: show large nav bar or not
    func configureNavigationBar(largeTitleColor: UIColor, backgoundColor: UIColor, tintColor: UIColor, title: String, preferredLargeTitle: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = preferredLargeTitle
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = tintColor
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
         //   navBarAppearance.configureWithDefaultBackground()
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: largeTitleColor, .font: FontFamily.Tinos.regular.font(size: 30)]
            navBarAppearance.titleTextAttributes = [.foregroundColor: largeTitleColor]
            navBarAppearance.backgroundColor = backgoundColor
            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.compactAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
            navigationItem.title = title

        } else {
            // Fallback on earlier versions
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: largeTitleColor, .font: FontFamily.Tinos.regular.font(size: 30)]
            navigationController?.navigationBar.barTintColor = backgoundColor
            navigationItem.title = title
        }
        navigationController?.navigationBar.sizeToFit()
    }

    func showAlertVC(message: String) {
        let alertVC = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)

        alertVC.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))

        present(alertVC, animated: true, completion: nil)
    }
}

extension UIViewController {
    /// Remove specific child View Controller from itself
    ///
    /// - Parameters:
    ///   - controller: ViewController need to be added.
    ///   - containerView: ContainerView contains ViewController's view.
    ///   - byConstraints: Adjust contraint mask to supperview (top, bottom, left, right)
    func addChildViewController(controller: UIViewController, containerView: UIView, byConstraints: Bool = false) {
        containerView.addSubview(controller.view)
        addChild(controller)
        controller.didMove(toParent: self)

        controller.view.frame = containerView.bounds
    }

    /// Remove All child ViewControllers from itself
    func removeAllChildViewController() {
        children.forEach {
            removeChildViewController($0)
        }
    }

    /// Remove specific child View Controller from itself except a specific Tag ViewController's View
    func removeAllChildViewControllerExcept(viewByTag tag: Int?) {
        children.forEach {
            if $0.view.tag != tag {
                removeChildViewController($0)
            }
        }
    }

    /// Remove specific child View Controller from itself
    func removeChildViewController(_ viewController: UIViewController) {
        viewController.didMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
