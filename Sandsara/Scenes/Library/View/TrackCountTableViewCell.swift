//
//  TrackCountTableViewCell.swift
//  Sandsara
//
//  Created by Tín Phan on 09/12/2020.
//

import UIKit
import RxCocoa
import RxSwift

class TrackCountTableViewCell: BaseTableViewCell<DownloadCellViewModel> {
    @IBOutlet private weak var notSyncedCountLabel: UILabel!
    @IBOutlet private weak var timeRemaingLabel: UILabel!
    @IBOutlet private weak var syncAllBtn: UIButton!

    let playlistTrigger = PublishRelay<()>()

    override func awakeFromNib() {
        super.awakeFromNib()
        syncAllBtn.setTitle(L10n.syncAll, for: .normal)
        timeRemaingLabel.isHidden = true
    }

    override func bindViewModel() {
        syncAllBtn
            .rx.tap
            .bind(to: playlistTrigger)
            .disposed(by: disposeBag)

        viewModel
            .outputs
            .notSyncedTrack
            .driveNext { [weak self] value in
                guard let self = self else { return }
                self.syncAllBtn.isHidden = value == 0
                self.notSyncedCountLabel.text = L10n.xTrackNeedToBeSynced(value)
            }.disposed(by: disposeBag)

        viewModel
            .outputs
            .timeRemaining?
            .driveNext { [weak self] value in
                guard let self = self else { return }
                self.timeRemaingLabel.text = L10n.xMinEsimated(value)
                self.timeRemaingLabel.isHidden = value == "" || value == "0.0"
            }.disposed(by: disposeBag)
    }
}
