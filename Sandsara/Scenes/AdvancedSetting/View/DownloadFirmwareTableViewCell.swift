//
//  DownloadFirmwareTableViewCell.swift
//  Sandsara
//
//  Created by Tín Phan on 31/12/2020.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD


/// State of Download firmware
private enum DownloadFirmwareState {
    case notDownloaded
    case downloading
    case downloaded
    case syncing
    case synced
}


/// Contract of DownloadFirmwareVM
enum DownloadFirmwareVMContract {
    struct Input: InputType {
        var latestVersion: String
        var file: File?
    }

    struct Output: OutputType {
        var latestVersion: Driver<String>
    }
}


/// DownloadFirmwareViewModel, indicate the state of a firmware
class DownloadFirmwareViewModel: BaseCellViewModel<DownloadFirmwareVMContract.Input, DownloadFirmwareVMContract.Output> {
    override func transform() {
        setOutput(Output(latestVersion: Driver.just(inputs.latestVersion)))
    }
}


/// Firmware Cell , show full state of downloaded or not downloaded , etc
class DownloadFirmwareTableViewCell: BaseTableViewCell<DownloadFirmwareViewModel> {
    private var state: DownloadFirmwareState = .notDownloaded {
        didSet {
            updateUIState()
        }
    }
    
    // MARK: - UI Outlet connections between swift file and xib/ storyboard file
    @IBOutlet weak var titleSyncLabel: UILabel!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var alertLabel: UILabel!

    // MARK: - Properties
    let cellUpdate = PublishRelay<()>()
    let updateFirmwareAlert = PublishRelay<DisplayItem>()
    let latestVersion = BehaviorRelay<String>(value: "")
    var filePath: URL?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        progressBar.progress = 0
    }

    override func bindViewModel() {
        viewModel
            .outputs.latestVersion
            .doOnNext { _ in
                self.updateUIState()
            }
            .drive(latestVersion).disposed(by: disposeBag)

        downloadBtn.rx.tap.subscribeNext {
            if self.state == .notDownloaded {
                self.state = .downloading
                self.triggerDownload()
            } else if self.state == .downloaded {
                self.state = .syncing
                self.triggerSync()
            }
        }.disposed(by: disposeBag)
    }
    
    
    /// Update cell UI Trigger by state
    func updateUIState() {
        DispatchQueue.main.async {
            switch self.state {
            case .notDownloaded:
                self.titleSyncLabel.text = L10n.firmwareAlert(self.latestVersion.value)
                self.downloadBtn.setTitle(L10n.download, for: .normal)
                self.alertLabel.text = ""
            case .downloading:
                self.titleSyncLabel.text = L10n.firmwareDownloading(self.latestVersion.value)
                self.downloadBtn.setTitle(L10n.downloading, for: .normal)
                self.alertLabel.text = ""
                self.downloadBtn.isUserInteractionEnabled = false
            case .downloaded:
                self.titleSyncLabel.text = L10n.firmwareIsReady(self.latestVersion.value)
                self.downloadBtn.setTitle(L10n.firmwareUpdateNow, for: .normal)
                self.alertLabel.text = L10n.firmwareNotice
                self.downloadBtn.isUserInteractionEnabled = true
                self.progressBar.setProgress(0, animated: true)
                self.progressBar.isHidden = true
            case .syncing:
                self.titleSyncLabel.text = L10n.firmwareSyncing(self.latestVersion.value)
                self.downloadBtn.setTitle(L10n.syncing, for: .normal)
                self.alertLabel.text = ""
            case .synced:
                break
            }
        }

        cellUpdate.accept(())
    }
    
    
    /// Download button action
    func triggerDownload() {
        guard let file = viewModel.inputs.file else { return }
        let item = DisplayItem(file: file)

        guard let url = URL(string: item.fileURL) else { return }

        let operation = DownloadManager.shared.queueDownload(url, item: item)
        let completion = BlockOperation {
            self.state = .downloaded
            self.filePath = operation.filePath
        }

        operation.addDependency(completion)
        OperationQueue.main.addOperation(completion)
        operation.progress.bind(to: self.progressBar.rx.progress).disposed(by: disposeBag)
    }

    /// Sync button action
    func triggerSync() {
        self.updateFirmwareAlert.accept(DisplayItem(file: self.viewModel.inputs.file ?? File()))
    }
}
