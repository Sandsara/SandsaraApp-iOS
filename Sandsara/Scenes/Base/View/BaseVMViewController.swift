//
//  BaseVMViewController.swift
//  Sandsara
//
//  Created by Tín Phan on 11/7/20.
//

import UIKit

// MARK: - BaseVMViewController
struct NotInputParam: InputParamView {}
class BaseVMViewController<VMElement: ViewModelType, Input: InputParamView>:
    BaseViewController<Input>, ViewModelBindable {
    typealias ViewModel = VMElement
    var viewModel: ViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewModel()
        bindViewModel()
        viewModel.viewModelDidBind()
    }

    /// Handle setup ViewModel and Its inputs
    func setupViewModel() {
        fatalError("All subsclass must implement this method to initialise ViewModel")
    }

    /// Handle binding data to display on UI
    func bindViewModel() {
        fatalError("All subsclass must implement this method to bind data from VM -> UI View")
    }

    
}
