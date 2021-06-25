//
//  EmptyCell.swift
//  Sandsara
//
//  Created by Tín Phan on 28/11/2020.
//

import UIKit

class EmptyCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = FontFamily.OpenSans.semibold.font(size: 14)
        titleLabel.text = L10n.emptyList
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
