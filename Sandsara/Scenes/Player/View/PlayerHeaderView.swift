//
//  PlayerHeaderView.swift
//  Sandsara
//
//  Created by Tín Phan on 27/11/2020.
//

import UIKit
import RxCocoa
import RxSwift

class PlayerHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songAuthorLabel: UILabel!
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var nextByLabel: UILabel!
    @IBOutlet weak var nextByLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextByLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var nowPlayingLabel: UILabel!

    let disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundView(color: Asset.background.color)
        songTitleLabel.textColor = Asset.primary.color
        songAuthorLabel.textColor = Asset.secondary.color
        songTitleLabel.font = FontFamily.Tinos.regular.font(size: 30)
        songAuthorLabel.font = FontFamily.OpenSans.regular.font(size: 14)
        nextByLabel.text = L10n.nextBy
        nextByLabel.font = FontFamily.OpenSans.regular.font(size: 14)
        nowPlayingLabel.text = L10n.nowPlaying
    }
    
    // MARK: Reload function when now playing track is changed
    func reloadHeaderCell(trackDisplay: Driver<DisplayItem>, trackCount: Driver<Int>) {
        trackDisplay.driveNext { [weak self] track in
            self?.songTitleLabel.text = track.title
            self?.songAuthorLabel.text = L10n.authorBy(track.author)
            self?.trackImageView.kf.setImage(with: URL(string: track.thumbnail))
        }.disposed(by: disposeBag)

        trackCount.driveNext {
            self.updateConstraints(condition: $0 > 0)
        }.disposed(by: disposeBag)
    }
    
    // MARK: if the track is empty then the condition is false
    func updateConstraints(condition: Bool) {
        nextByLabel.isHidden = !condition
        nextByLabelTopConstraint.constant = condition ? 41.0 : 0.0
        nextByLabelBottomConstraint.constant = condition ? 20.0 : 0.0
    }
}
