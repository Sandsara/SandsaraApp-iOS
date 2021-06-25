//
//  MenuTableViewCell.swift
//  Sandsara
//
//  Created by Tín Phan on 11/11/20.
//

import UIKit

class MenuTableViewCell: BaseTableViewCell<MenuCellViewModel> {

    @IBOutlet private weak var titleLabel: UILabel!
    
    // MARK: UI setup
    override func awakeFromNib() {
        selectionStyle = .none
        titleLabel.font = FontFamily.OpenSans.regular.font(size: 18)
    }
    
    // MARK: UI Binding function with MenuCellViewModel
    override func bindViewModel() {
        /// Color title label set, we can customize the color by modify MenuCellViewModel.
        /// For the advance setting, please read AdvanceSettingViewModel, func buildCellVM. Default Color is Primary Color on Figma
        titleLabel.textColor = viewModel.inputs.color
        
        // Cell Title base on SettingItemType
        viewModel
            .outputs
            .title
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
