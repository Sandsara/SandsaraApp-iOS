//
//  ViewModelBindable.swift
//  HighJump
//
//  Created by Duy Le Ngoc on 8/8/19.
//  Copyright © 2019 VISA. All rights reserved.
//

import RxSwift

// MARK: Base Protocol for binding with ViewModel from View
protocol ViewModelBindable: class {
    associatedtype ViewModel

    var viewModel: ViewModel! { get set }
    func bindViewModel()
}

extension ViewModelBindable where Self: UIViewController {
    func bind(to viewModel: Self.ViewModel) {
        self.viewModel = viewModel
        loadViewIfNeeded()
        bindViewModel()
    }
}

extension ViewModelBindable where Self: UIView {
    func bind(to viewModel: Self.ViewModel) {
        self.viewModel = viewModel
        bindViewModel()
    }
}
