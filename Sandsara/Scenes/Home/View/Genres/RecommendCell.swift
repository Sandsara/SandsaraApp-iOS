//
//  GenreCollectionViewCell.swift
//
//
//  Created by tin on 5/18/20.
//  Copyright © 2020 tin. All rights reserved.
//

import UIKit
import Kingfisher

class RecommendCell: BaseCollectionViewCell<RecommendCellViewModel> {

    @IBOutlet weak var genreImageView: UIImageView!

    override func bindViewModel() {
        genreImageView.kf.indicatorType = .activity
        genreImageView.kf.setImage(with: viewModel.outputs.url)
    }
}
