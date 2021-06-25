//
//  NVActivityIndicatorView.swift
//  Sandsara
//
//  Created by Tín Phan on 11/7/20.
//

import RxSwift
import RxCocoa
import NVActivityIndicatorView
import UIKit

// MARK: - Reactive for NVActivityIndicatorView
extension Reactive where Base: NVActivityIndicatorView {
    var isAnimating: Binder<Bool> {
        return Binder(base) { (indicator, isAnimating) in
            if isAnimating {
                indicator.startAnimating()
            } else {
                indicator.stopAnimating()
            }
        }
    }
}


extension Reactive where Base: ToggleSwitch {
    var isOn: Binder<Bool> {
        return Binder(base) { (indicator, isOn) in
            indicator.setOn(on: isOn, animated: true)
        }
    }
}
