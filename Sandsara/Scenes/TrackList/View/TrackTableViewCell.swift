//
//  TrackTableViewCell.swift
//  Sandsara
//
//  Created by Tín Phan on 11/12/20.
//

import UIKit
import Kingfisher

class TrackTableViewCell: BaseTableViewCell<TrackCellViewModel> {

    @IBOutlet private weak var syncBtn: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var trackImageView: UIImageView!
    @IBOutlet private weak var syncBtnTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var syncBtnLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var syncBtnWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var progressView: UIProgressView!

    var state: TrackState = .download {
        didSet {
            trackDetailUIConfig()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = Asset.background.color
        titleLabel.textColor = Asset.primary.color
        authorLabel.textColor = Asset.secondary.color
        titleLabel.font = FontFamily.OpenSans.semibold.font(size: 14)
        authorLabel.font = FontFamily.OpenSans.light.font(size: 10)
        progressView.isHidden = false
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        if syncBtn.isRotating {
            syncBtn.rotate360Degrees()
        }
    }

    override func bindViewModel() {
        viewModel
            .inputs
            .downloadTrigger?
            .subscribeNext {
                if !DataLayer.loadDownloadedTrack(LocalTrack(track: self.viewModel.inputs.track)) {
                    self.progressView.isHidden = false
                    self.downloadAction()
                }
        }.disposed(by: disposeBag)

        viewModel
            .inputs
            .syncTrigger?.subscribeNext {
                if !DataLayer.checkTrackIsSynced(self.viewModel.inputs.track) {
                    self.syncAction()
                }
            }.disposed(by: disposeBag)

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

        viewModel
            .outputs
            .saved
            .driveNext {
                self.updateConstraints(isSynced: $0)
        }.disposed(by: disposeBag)

        syncBtn
            .rx.tap.subscribeNext {
                self.syncAction()
        }.disposed(by: disposeBag)

        if viewModel.inputs.mode == .local {
            self.checkDownloaed()
        } else {
            self.updateConstraints(isSynced: true)
        }
    }

    func updateConstraints(isSynced: Bool) {
        syncBtn.alpha = isSynced ? 0 :1
        syncBtn.isHidden = isSynced
        syncBtnTrailingConstraint.constant = isSynced ? 0 : 16
        syncBtnWidthConstraint.constant = isSynced ? 0 : 30
        syncBtnLeadingConstraint.constant = isSynced ? 16 : 10
        progressView.isHidden = isSynced
    }

    func checkDownloaed() {
        let item = viewModel.inputs.track
        let downloaded = DataLayer.loadDownloadedTrack(LocalTrack(track: item))
        DispatchQueue.main.async {
            self.state = downloaded ? .downloaded : .download
            if self.state == .downloaded {
                self.updateConstraints(isSynced: true)
            }
        }
    }

    private func trackDetailUIConfig() {
        updateConstraints(isSynced: true)
    }

    private func downloadAction() {
        let track = viewModel.inputs.track
        let completion = BlockOperation {
            print("downloaded \(self.viewModel.inputs.track.fileName) is done")
            self.progressView.isHidden = true
            self.progressView.progress = 0
        }
        let name = track.fileName; let size = track.fileSize; let urlString = track.fileURL
        guard let url = URL(string: urlString) else { return }
        let resultCheck = FileServiceImpl.shared.existingFile(fileName: name)
        if resultCheck.0 == false || resultCheck.1 < size {
            let operation = DownloadManager.shared.queueDownload(url, item: track)
            print(operation.progress.value)
            operation
                .progress.bind(to: self.progressView.rx.progress)
                .disposed(by: disposeBag)
            completion.addDependency(operation)
            OperationQueue.main.addOperation(completion)
        } else {
            _ = DataLayer.addDownloadedTrack(track)
        }
    }

    private func syncAction() {
        syncBtn.rotate360Degrees()
        progressView.isHidden = false
        let track = viewModel.inputs.track

        let completion = BlockOperation {
            self.checkSynced()
            print("Synced \(self.viewModel.inputs.track.fileName) is done")
            self.progressView.isHidden = true
            self.progressView.progress = 0
            self.syncBtn.stopRotation()
        }

        let operation = FileSyncManager.shared.queueDownload(item: track)
        operation.progress
            .bind(to: self.progressView.rx.progress)
            .disposed(by: operation.disposeBag)

        FileSyncManager.shared.triggerOperation(id: track.trackId)

        completion.addDependency(operation)

        OperationQueue.main.addOperation(completion)

    }

    private func getCurrentSyncTask(item: DisplayItem) {
        if let task = FileSyncManager.shared.findCurrentQueue(item: item) {
            self.progressView.isHidden = false
            self.syncBtn.rotate360Degrees()
            task.progress
                .bind(to: self.progressView.rx.progress)
                .disposed(by: task.disposeBag)
        } else {
            progressView.isHidden = true
        }
    }

    private func checkSynced() {
        let synced = DataLayer.checkTrackIsSynced(viewModel.inputs.track)
        DispatchQueue.main.async {
            self.state = synced ? .synced : .downloaded
            if !synced {
                self.getCurrentSyncTask(item: self.viewModel.inputs.track)
            } else {
                self.updateConstraints(isSynced: true)
            }
        }
    }
}
