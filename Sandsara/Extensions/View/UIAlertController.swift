//
//  UIAlertController.swift
//  Sandsara
//
//  Created by Tín Phan on 11/7/20.
//

import UIKit
import RxCocoa
import RxSwift

struct ActionSheetItem<Type> {
    let title: String
    let selectType: Type
    let style: UIAlertAction.Style
    let textColor: UIColor
}

extension UIAlertController {
    func addAction<T>(actions: [ActionSheetItem<T>], cancelMessage: String, cancelAction: ((UIAlertAction) -> Void)?) -> Observable<T> {
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            actions.map { action ->  UIAlertAction in
                let alertAction = UIAlertAction(title: action.title,
                                                style: action.style) { _ in
                    observer.onNext(action.selectType)
                    observer.onCompleted()
                }
                alertAction.setValue(action.textColor, forKey: "titleTextColor")
                return alertAction
            }.forEach { [weak self] in
                guard let self = self else { return }
                self.addAction($0)
            }

            let cancelAction = UIAlertAction(title: cancelMessage, style: .cancel) {
                cancelAction?($0)
                observer.onCompleted()
            }

            self.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor.white
            self.addAction(cancelAction)

            return Disposables.create { [weak self] in
                guard let self = self else { return }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension UIViewController {
    func showAlert(title: String?,
                   message: String?,
                   preferredStyle: UIAlertController.Style,
                   actions: UIAlertAction...) {
        let alertViewController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: preferredStyle)
        for action in actions {
            alertViewController.addAction(action)
        }

        present(alertViewController, animated: true, completion: nil)
    }
}

extension UIView {
    func rotate360Degrees(duration: CFTimeInterval = 1, repeatCount: Float = .infinity) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2)
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = repeatCount
        layer.add(rotateAnimation, forKey: "rotate")
    }

    func stopRotation () {
        layer.removeAllAnimations()
    }

    var isRotating: Bool {
        return (layer.animation(forKey: "rotate") != nil)
    }
}

import SnapKit
class LoadingButton: UIButton {

    struct ButtonState {
        var state: UIControl.State
        var title: String?
        var image: UIImage?
    }

    private (set) var buttonStates: [ButtonState] = []
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = self.titleColor(for: .normal)
        self.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        return activityIndicator
    }()

    func showLoading() {
        activityIndicator.startAnimating()
        var buttonStates: [ButtonState] = []
        for state in [UIControl.State.disabled] {
            let buttonState = ButtonState(state: state, title: title(for: state), image: image(for: state))
            buttonStates.append(buttonState)
          //  setTitle("", for: state)
            setImage(UIImage(), for: state)
        }
        self.buttonStates = buttonStates
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: titleLabel?.text != nil ? 25 : 0, bottom: 0, right: 0)
        isEnabled = false
    }

    func hideLoading() {
        activityIndicator.stopAnimating()
        for buttonState in buttonStates {
            setTitle(buttonState.title, for: buttonState.state)
            setImage(buttonState.image, for: buttonState.state)
        }
        isEnabled = true
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

}
