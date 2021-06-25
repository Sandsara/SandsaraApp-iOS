//
//  HeaderView.swift
//  IWA Test
//
//  Created by tin on 5/14/20.
//  Copyright © 2020 iwa. All rights reserved.
//

import UIKit


class SettingHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: UI Setup
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundView(color: Asset.background.color)
        titleLabel.font = FontFamily.Tinos.regular.font(size: 25)
        titleLabel.textColor = Asset.primary.color
    }
}
