//
//  PlaylistTableViewCell.swift
//  Sandsara
//
//  Created by Tín Phan on 11/12/20.
//

import UIKit

class PlaylistTableViewCell: BaseTableViewCell<PlaylistCellViewModel> {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var trackImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = Asset.background.color
        titleLabel.textColor = Asset.primary.color
        authorLabel.textColor = Asset.secondary.color
        titleLabel.font = FontFamily.OpenSans.semibold.font(size: 14)
        authorLabel.font = FontFamily.OpenSans.light.font(size: 10)
    }

    override func bindViewModel() {
        viewModel
            .outputs
            .title
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel
            .outputs
            .authorTitle
            .drive(authorLabel.rx.text)
            .disposed(by: disposeBag)

        trackImageView.kf.indicatorType = .activity
        trackImageView.kf.setImage(with: viewModel.outputs.thumbnailUrl)
    }

}
