//
//  ColorCell.swift
//  Sandsara
//
//  Created by Tín Phan on 27/11/2020.
//

import UIKit

class ColorCell: BaseCollectionViewCell<PresetCellViewModel> {

    // MARK: Outlet connections between swift file and xib/ storyboard file between swift file and xib file
    @IBOutlet weak var gradientView: GradientView!

    // MARK: UI Setup
    override func awakeFromNib() {
        super.awakeFromNib()
        /// Gradient view setup, currently gradientview show in the app is Linear and direction is Horizontal
        gradientView.mode = .linear
        gradientView.direction = .horizontal
        gradientView.layer.cornerRadius = gradientView.frame.size.width / 2
        gradientView.clipsToBounds = true
    }
    
    // MARK: UI Binding function with PresetCellViewModel
    override func bindViewModel() {
        /// Color output return from ColorModel
        viewModel
            .outputs
            .color
            .driveNext { color in
                /// Set colors for gradient
                self.gradientView.colors = color.colors.map {
                    UIColor(hexString: $0)
                }
                /// Set colors gradient's locations
                self.gradientView.locations = color.position.map {
                    CGFloat($0) / 255.0
                }
                self.layoutIfNeeded()
            }
            .disposed(by: disposeBag)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientView.layer.cornerRadius = gradientView.frame.size.width / 2
        gradientView.clipsToBounds = true
    }
}
