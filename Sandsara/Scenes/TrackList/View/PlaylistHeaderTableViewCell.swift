//
//  PlaylistHeaderTableViewCell.swift
//  Sandsara
//
//  Created by Tín Phan on 22/11/2020.
//

import UIKit
import RxSwift
import RxCocoa

struct Matrix<T> {
    let rows: Int, columns: Int
    var grid: [T]
    init(rows: Int, columns: Int,defaultValue: T) {
        self.rows = rows
        self.columns = columns
        grid = Array(repeating: defaultValue, count: rows * columns) as! [T]
    }
    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    subscript(row: Int, column: Int) -> T {
        get {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
}

class PlaylistHeaderTableViewCell: BaseTableViewCell<PlaylistDetailHeaderViewModel> {
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songAuthorLabel: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var playlistCoverImage: ImageGridView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var downloadButton: ProgressButtonUIView!
    @IBOutlet weak var syncButton: ProgressButtonUIView!
    
    let backAction = PublishRelay<()>()
    
    let playAction = PublishRelay<()>()
    
    let deleteAction = PublishRelay<()>()
    
    let playlistTrigger = PublishRelay<()>()
    
    var images = [UIImage]()
    
    var expectedImages = [UIImage]()
    
    var state: TrackState = .download {
        didSet {
            trackDetailUIConfig()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        playlistCoverImage.datasource = self
        playlistCoverImage.maxCapacity = 12
        
        songTitleLabel.textColor = Asset.primary.color
        songAuthorLabel.textColor = Asset.secondary.color
        songTitleLabel.font = FontFamily.Tinos.regular.font(size: 30)
        songAuthorLabel.font = FontFamily.OpenSans.regular.font(size: 14)
    }
    
    override func bindViewModel() {
        downloadButton.setupUI(title: L10n.download,
                               image: Asset.download.image,
                               font: FontFamily.OpenSans.regular.font(size: 18),
                               inProgressTitle: L10n.downloading,
                               color: Asset.primary.color)
        
        syncButton.setupUI(title: L10n.syncToBoard,
                           image: Asset.sync1.image,
                           font: FontFamily.OpenSans.regular.font(size: 18),
                           inProgressTitle: L10n.syncing,
                           color: Asset.primary.color)
        
        viewModel
            .outputs
            .isFavoriteList
            .drive(deleteButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel
            .outputs
            .title
            .drive(songTitleLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.outputs.authorTitle.drive(songAuthorLabel.rx.text).disposed(by: disposeBag)
        
        playBtn.rx.tap.bind(to: playAction).disposed(by: disposeBag)
        
        backBtn.rx.tap.bind(to: backAction).disposed(by: disposeBag)
        
        deleteButton.rx.tap.bind(to: deleteAction).disposed(by: disposeBag)
        
        let completion = BlockOperation {
            defer {
                self.processHeaderImage()
            }
            for track in self.viewModel.inputs.track.tracks {
                let fileName = track.thumbNailfileName
                do {
                    if let imageURL = try? FileManager.default
                        .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                        .appendingPathComponent(fileName) {
                        if let data = try? Data(contentsOf: imageURL), let image = UIImage(data: data) {
                            self.images.append(image)
                        }
                    }
                }
                catch {
                }
                
            }
        }
        for track in viewModel.inputs.track.tracks {
            let name = track.thumbNailfileName; let size = track.thumbNailfileSize; let urlString = track.thumbnail;
            guard let url = URL(string: urlString) else { continue }
            let resultCheck = FileServiceImpl.shared.existingFile(fileName: name)
            if resultCheck.0 == false || resultCheck.1 < size {
                let operation = ImageDownloadManager.shared.queueDownload(url)
                completion.addDependency(operation)
            }
        }
        OperationQueue.main.addOperation(completion)
        
        downloadButton.touchEvent = { [weak self] in
            self?.downloadAction()
        }
        
        syncButton.touchEvent = { [weak self] in
            self?.syncAction()
        }
        checkDownloaed()
    }
    
    private func downloadAction() {
        let track = viewModel.inputs.track
        let completion = BlockOperation {
            self.checkDownloaed()
            self.playlistTrigger.accept(())
        }
        let name = track.fileName; let size = track.fileSize; let urlString = track.fileURL
        if let url = URL(string: urlString) {
            let resultCheck = FileServiceImpl.shared.existingFile(fileName: name)
            if resultCheck.0 == false || resultCheck.1 < size {
                let operation = DownloadManager.shared.queueDownload(url, item: track)
                print(operation.progress.value)
                operation
                    .progress.bind(to: self.downloadButton.progressBar.rx.progress)
                    .disposed(by: operation.disposeBag)
                completion.addDependency(operation)
                OperationQueue.main.addOperation(completion)
            }
        } else {
            let completion = BlockOperation {
                print("all done")
            }
            
            for track in self.viewModel.inputs.track.tracks {
                let name = track.fileName; let size = track.fileSize; let urlString = track.fileURL
                guard let url = URL(string: urlString) else { continue }
                let resultCheck = FileServiceImpl.shared.existingFile(fileName: name)
                if resultCheck.0 == false || resultCheck.1 < size {
                    let operation = DownloadManager.shared.queueDownload(url, item: track)
                    completion.addDependency(operation)
                } else {
                    _ = DataLayer.addDownloadedTrack(track)
                }
            }
            OperationQueue.main.addOperation(completion)
            self.playlistTrigger.accept(())
            _ = DataLayer.createDownloaedPlaylist(playlist: track)
            self.checkDownloaed()
        }
    }
    
    private func getCurrentSyncTask(item: DisplayItem) {
        if let task = FileSyncManager.shared.findCurrentQueue(item: item) {
            DispatchQueue.main.async {
                self.syncButton.isTaskRunning = true
            }
            task.progress
                .bind(to: self.syncButton.progressBar.rx.progress)
                .disposed(by: task.disposeBag)
        }
    }
    
    private func syncAction() {
        let track = viewModel.inputs.track
        let completion = BlockOperation {
            self.checkSynced()
        }
        
        let operation = FileSyncManager.shared.queueDownload(item: track)
        operation.progress
            .bind(to: self.syncButton.progressBar.rx.progress)
            .disposed(by: operation.disposeBag)
        
        FileSyncManager.shared.triggerOperation(id: track.trackId)
        
        completion.addDependency(operation)
        
        OperationQueue.main.addOperation(completion)
    }
    
    private func checkSynced() {
        DispatchQueue.main.async {
            self.state = .downloaded
        }
    }
    
    func checkDownloaed() {
        guard !viewModel.inputs.track.isTestPlaylist && !viewModel.inputs.track.isLocal
        else {
            checkSynced(); return
        }
        let item = viewModel.inputs.track
        let downloaded = DataLayer.loadDownloadedDetail(name: item.title)
        DispatchQueue.main.async {
            self.state = downloaded ? .downloaded : .download
        }
    }
    
    private func trackDetailUIConfig() {
        playBtn.isHidden = state == .download
        downloadButton.isHidden = state == .downloaded
        syncButton.isHidden = state == .downloaded || state == .download
    }
    
    func processHeaderImage() {
        guard images.count > 0 else {
            print("No image")
            return
        }
        
        var images = self.images
        
        if images.count > 12 {
            images = Array(images.prefix(12))
        }
        
        var firstRows = [UIImage]()
        var secondRows = [UIImage]()
        var thirdRows = [UIImage]()
        
        var expectedValues = [UIImage]()
        
        var dividedValue = 12 / images.count
        while (dividedValue > 0) {
            expectedValues.append(contentsOf: images)
            dividedValue -= 1
        }
        
        var remainder = fabs((12.0).remainder(dividingBy: Double(images.count)))
        
        if remainder == 2 {
            remainder = 5
        }
        
        if remainder > 0 {
            let array = Array(images.prefix(Int(remainder)))
            expectedValues.append(contentsOf: array)
        }
        
        firstRows = Array(expectedValues.prefix(4))
        
        secondRows = Array(expectedValues[5 ..< 9])
        
        thirdRows = Array(expectedValues[9 ..< 12])
        
        var expectedFirstRows = [UIImage?]()
        var expectedSecondRows = [UIImage?]()
        var expectedThirdRows = [UIImage?]()
        
        for image in firstRows {
            expectedFirstRows.append(image.splitedInFourParts.shuffled().first)
        }
        
        for image in secondRows {
            expectedSecondRows.append(image.splitedInFourParts.shuffled().first)
        }
        
        for image in thirdRows {
            expectedThirdRows.append(image.splitedInFourParts.shuffled().first)
        }
        
        expectedImages = expectedFirstRows.compactMap { $0 } + expectedSecondRows.compactMap { $0 } + expectedThirdRows.compactMap { $0 }
        
        DispatchQueue.main.async {
            self.playlistCoverImage.reload()
        }
        
    }
    
}

extension PlaylistHeaderTableViewCell: ImageGridViewDatasource {
    func imageGridViewImages(_ imageGridView: ImageGridView) -> [UIImage] {
        return expectedImages
    }
}
