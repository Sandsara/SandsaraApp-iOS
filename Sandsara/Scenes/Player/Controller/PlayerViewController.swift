//
//  PlayerViewController.swift
//  Sandsara
//
//  Created by Tín Phan on 11/12/20.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Bluejay

enum PlayingState {
    case playlist
    case track
    case showOnly
}

class PlayerViewController: BaseViewController<NoInputParam> {
    
    // MARK: Player shared instance to use all the place in the app. Just need to create player one time only
    static var shared: PlayerViewController = {
        let playerVC = UIStoryboard(name: "Main",
                                    bundle: nil)
            .instantiateViewController(withIdentifier: PlayerViewController.identifier)
            as! PlayerViewController
        return playerVC
    }()
    
    @IBOutlet private weak var tableView: UITableView!
    var index: Int = 0
    var tracks = [DisplayItem]()
    var queues = [DisplayItem]()
    var sliderValue: Float = 0.0
    var currentTrack = DisplayItem()
    /// Variable to trigger reload UI when user play a new playlist or play a new track
    var isReloaded = false
    /// Playing mode for play a whole playlist or play a track and add it to current playlist
    var playlingState: PlayingState = .playlist
    var playingTrackCount = 0
    
    /// Playlist item indicate playlist name, playlist tracks
    var playlistItem: DisplayItem?
    
    /// A track is selected by user in TrackDetail
    var firstPriorityTrack: DisplayItem?
    
    /// Timer for progress tracking
    var timer: Timer?
    var lastProgress: Float = 0.0
    @IBOutlet weak var overlayView: UIView!
    var progress = BehaviorRelay<Float>(value: 0)
    
    @IBOutlet weak var trackProgressSlider: UISlider!
    @IBOutlet weak var prevBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var syncProgressBar: UIProgressView!
    @IBOutlet weak var remainTrackCountLabel: UILabel!
    
    var notSyncedTracks = [DisplayItem]()
    var isPlaying = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // MARK: Reload logic when user play a new playlist or play a new track
        if isReloaded {
            /// if user want to play a track, pass playingState is track and pass a firstPriorityTrack
            if playlingState == .track {
                if let firstPriority = firstPriorityTrack {
                    tracks.append(firstPriority)
                    if tracks.count > 1 {
                        queues = Array(tracks[index + 1 ..< tracks.count]) + Array(tracks[0 ..< index])
                    } else {
                        queues = tracks
                    }
                    addToQueue(track: firstPriority)
                    showTrack(at: self.tracks.count - 1)
                }
            } else {
                /// if user want to play a playlist, pass playingState is playlist
                showTrack(at: index)
                if playlingState == .playlist {
                    checkMultipleTracks()
                } else {
                    createPlaylist()
                }
            }
        }
    }
    
    // MARK: Tableview and UI Setup
    private func setupTableView() {
        tableView.backgroundColor = Asset.background.color
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(TrackTableViewCell.nib, forCellReuseIdentifier: TrackTableViewCell.identifier)
        tableView.register(PlayerHeaderView.nib, forHeaderFooterViewReuseIdentifier: PlayerHeaderView.identifier)
        tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        // MARK: Player control action
        nextBtn.addTarget(self, action: #selector(nextBtnTap), for: .touchUpInside)
        prevBtn.addTarget(self, action: #selector(prevBtnTap), for: .touchUpInside)
        trackProgressSlider.minimumValue = 0
        trackProgressSlider.maximumValue = 100 // not sure
        
        for state: UIControl.State in [.normal, .selected, .application, .reserved] {
            trackProgressSlider.setThumbImage(Asset.thumbs.image, for: state)
        }
        
        // MARK: Track progress slider gesture
        trackProgressSlider.addTarget(self, action: #selector(sliderTouchValueChanged(_:)), for: .valueChanged)
        trackProgressSlider.addTarget(self, action: #selector(sliderTouchBegan(_:)), for: .touchDown)
        trackProgressSlider.addTarget(self, action: #selector(sliderTouchEnded(_:)), for: [.touchUpInside, .touchCancel, .touchUpOutside])
        trackProgressSlider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sliderTapped(_:))))
        
        // MARK: Play btn action trigger
        playBtn.rx.tap.asDriver().driveNext { [weak self] in
            guard let self = self else { return }
            if self.isPlaying {
                self.isPlaying = false
                DeviceServiceImpl.shared.pauseDevice()
                self.pauseTimer()
                self.playBtn.setImage(Asset.play.image, for: .normal)
            } else {
                self.isPlaying = true
                DeviceServiceImpl.shared.resumeDevice()
                self.updateProgressTimer()
                self.playBtn.setImage(Asset.pause1.image, for: .normal)
            }
            self.popupBar.customBarViewController?.popupItemDidUpdate()
        }.disposed(by: disposeBag)
        
        progress
            .bind(to: trackProgressSlider.rx.value)
            .disposed(by: disposeBag)
    }
}

// MARK: UITableViewDelegate
extension PlayerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return playingTrackCount > 0 ? 96.0 : 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 400
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: PlayerHeaderView.identifier) as! PlayerHeaderView
        headerView.reloadHeaderCell(trackDisplay: Driver.just(currentTrack),
                                    trackCount: Driver.just(playingTrackCount))
        /// Header back button action
        headerView
            .backBtn
            .rx.tap.asDriver()
            .driveNext { [weak self] in
                self?.popupPresentationContainer?.closePopup(animated: true, completion: nil)
            }.disposed(by: headerView.disposeBag)
        return headerView
    }
    
    // MARK: Cell selection handler
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let trackInQueue = queues[safe: indexPath.row]
        
        guard let index = tracks.firstIndex(where: {
            $0.trackId == trackInQueue?.trackId
        }) else { return }
        triggerPlayAction(at: index)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        /// Recalculate header height
        guard let headerView = tableView.tableHeaderView else {return}
        let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            tableView.tableHeaderView = headerView
            tableView.layoutIfNeeded()
        }
    }
}

// MARK: UITableViewDataSource
extension PlayerViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackTableViewCell.identifier, for: indexPath) as? TrackTableViewCell,
              queues.count > 0
        else { return UITableViewCell() }
        
        cell.bind(to: TrackCellViewModel(inputs: TrackCellVMContract
                                            .Input(mode: .remote, track: queues[safe: indexPath.row] ?? DisplayItem())))
        
        return cell
    }
}

// MARK: - Player Method
extension PlayerViewController {
    
    // MARK: Create playlist function
    
    /// Create a playlist file then send to Sandsara
    func createPlaylist() {
        guard playlingState != .showOnly else {
            /// If we add to queue only, we need to resume the timer to read progress again, to achieve the correct UI State for player, for the case we first open the app and we go to the player
            /// The Default mode we open the player by tap the miniplayer first time is showOnly
            if timer != nil {
                timer?.invalidate()
                timer = nil
            }
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(updateTimer(_:)), userInfo: nil, repeats: true)
            return
        }
        
        /*
         Line 245 to 255, create playlist file by playlist name
         */
        let fileNames = tracks.map {
            $0.fileName
        }.joined(separator: "\r\n") 
        
        let filename = playlistItem?.title ?? "temporal"
        let fileExtension = "playlist"
        
        FileServiceImpl.shared.createOrOverwriteEmptyFileInDocuments(filename: filename + "." + fileExtension)
        if let handle = FileServiceImpl.shared.getHandleForFileInDocuments(filename: filename + "." + fileExtension) {
            FileServiceImpl.shared.writeString(string: fileNames, fileHandle: handle)
        }
        
        /// Trigger send file playlist file
        FileServiceImpl.shared.sendFiles(fileName: filename, extensionName: fileExtension, isPlaylist: true)
        /// After the send playlist is executed complety, sendSuccess will emit true, then we can trigger the playing behavior for Sandsara
        /// If we play a single track, a selected path will be a last track's index we add into the array
        /// If we play a playlist, a selected path will be a first index of the array
        FileServiceImpl.shared.sendSuccess.subscribeNext {
            if $0 {
                if self.isReloaded {
                    self.isReloaded = false
                    FileServiceImpl.shared.updatePlaylist(fileName: self.playlistItem?.title ?? "temporal",
                                                          index: self.playlingState == .track ? self.tracks.count : 1,
                                                          mode: self.playlingState) { success in
                        if success {
                            DeviceServiceImpl.shared.readPlaylistValue()
                            print("Play playlist \(self.playlistItem?.title ?? "temporal") success")
                            self.readProgress()
                        }
                    }
                }
            }
        }.disposed(by: disposeBag)
    }
    
    // MARK: update UI for user selected track or next track has been played automatically by Sandsara
    func showTrack(at index: Int) {
        DeviceServiceImpl.shared.currentTrackIndex = index
        sliderValue = 0
        queues = Array(tracks[index + 1 ..< tracks.count]) + Array(tracks[0 ..< index])
        currentTrack = tracks[index]
        playingTrackCount = queues.count
        self.index = index
        DispatchQueue.main.async {
            self.tableView.reloadData()
            if self.queues.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }
    
    // MARK: play user selected track immediately
    func playTrack(at index: Int) {
        FileServiceImpl.shared.updatePositionIndex(index: index + 1) { success in
            if success {
                self.isPlaying = true
                DeviceServiceImpl.shared.currentTrackPosition.accept(0)
                DispatchQueue.main.async {
                    self.readProgress()
                    (UIApplication.topViewController()?.tabBarController?.popupBar.customBarViewController as? PlayerBarViewController)?.state = .haveTrack(displayItem: self.tracks[index])
                }
            }
        }
    }
    
    // MARK: trigger update UI and play action
    func triggerPlayAction(at index: Int) {
        defer {
            showTrack(at: index)
            playTrack(at: index)
        }
        pauseTimer()
    }
    
    // MARK: Slider touch handle
    @objc func sliderTouchBegan(_ sender: UISlider) {
    }
    
    @objc func sliderTouchValueChanged(_ sender: UISlider) {
        let playTime = sender.value
        if playTime == sender.maximumValue {
            if index < tracks.count - 1 {
                let indexToPlay = index + 1
                triggerPlayAction(at: indexToPlay)
            }
        }
    }
    
    @objc func sliderTapped(_ gestureRecognizer: UIGestureRecognizer) {
        guard let slider = gestureRecognizer.view as? UISlider else { return }
        let pointTapped = gestureRecognizer.location(in: slider)
        
        let positionOfSlider = slider.bounds.origin
        let widthOfSlider = slider.bounds.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(slider.maximumValue) / widthOfSlider)
        slider.setValue(Float(newValue), animated: true)
    }
    
    @objc func sliderTouchEnded(_ sender: UISlider) {
        let playTime = sender.value
        if playTime == sender.maximumValue {
            if index < tracks.count - 1 {
                let indexToPlay = index + 1
                triggerPlayAction(at: indexToPlay)
            }
        }
    }
    
    // MARk: Next btn action
    @objc func nextBtnTap() {
        debugPrint("tapped next")
        if self.index < self.tracks.count - 1 {
            let indexToPlay = self.index + 1
            self.triggerPlayAction(at: indexToPlay)
        } else {
            let indexToPlay = 0
            self.triggerPlayAction(at: indexToPlay)
        }
    }
    
    // MARk: Previous btn action
    @objc func prevBtnTap() {
        debugPrint("tapped previous")
        if self.index > 0 {
            let indexToPlay = self.index - 1
            self.triggerPlayAction(at: indexToPlay)
        } else {
            let indexToPlay = self.tracks.count - 1
            self.triggerPlayAction(at: indexToPlay)
        }
    }
    
    // MARK: Add track to queue silently but not play
    func addToQueue1(track: DisplayItem) {
        tracks.append(track)
        if tracks.count > 1 {
            queues = Array(tracks[index + 1 ..< tracks.count]) + Array(tracks[0 ..< index])
        } else {
            queues = tracks
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        DeviceServiceImpl.shared.currentTracks = tracks
    }
    
    // MARK: Add track to queue, then
    
    /// check if track exist, if exist we will play it immediately, else we will sync to SD Card and play it after the sync progress is completed
    /// - Parameter track: track need to be check
    func addToQueue(track: DisplayItem) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        DeviceServiceImpl.shared.currentTracks = tracks
        
        checkTrackExist(track: track)
    }
    
    // MARK: - check single track
    func checkTrackExist(track: DisplayItem) {
        FileServiceImpl.shared.checkFileExistOnSDCard(name: track.fileName) { isExisted in
            if isExisted { 
                DispatchQueue.main.async {
                    /// if all the tracks is synced to Sd card of sandsara, call createPlaylist immediately to trigger playing behavior
                    self.createPlaylist()
                }
            } else {
                /// show overlay for sync files
                DispatchQueue.main.async {
                    (UIApplication.topViewController()?.tabBarController?.popupBar.customBarViewController as? PlayerBarViewController)?.state = .busy
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: OverlaySendFileViewController.identifier) as! OverlaySendFileViewController
                    vc.modalPresentationStyle = .overFullScreen
                    vc.notSyncedTracks = [track]
                    self.present(vc, animated: false)
                }
            }
        }
    }
        
    // MARK: - check multiple tracks 
    func checkMultipleTracks() {
        notSyncedTracks = []
        bluejay.run { sandsaraBoard -> Bool in
            for track in self.tracks {
                do {
                    let value: String = try sandsaraBoard.writeAndRead(writeTo: FileService.checkFileExist, value: track.fileName, readFrom: FileService.receiveFileRespone)
                    if value == "1" {
                        continue
                    } else {
                        self.notSyncedTracks.append(track)
                    }
                }
            }
            return false
        } completionOnMainThread: { result in
            switch result {
            case .success:
                print("checked all")
                /// if all the tracks is synced to Sd card of sandsara, call createPlaylist immediately to trigger playing behavior
                if self.notSyncedTracks.isEmpty {
                    self.createPlaylist()
                } else {
                    /// Stop reading progress and after that show overlay for sync files
                    self.progress.accept(0)
                    self.pauseTimer()
                    DispatchQueue.main.async {
                        (UIApplication.topViewController()?.tabBarController?.popupBar.customBarViewController as? PlayerBarViewController)?.state = .busy
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: OverlaySendFileViewController.identifier) as! OverlaySendFileViewController
                        vc.modalPresentationStyle = .overFullScreen
                        vc.notSyncedTracks = self.notSyncedTracks
                        self.present(vc, animated: false)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: Reinitial timer after track selection
    func updateProgressTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(updateTimer(_:)), userInfo: nil, repeats: true)
        }
    }
    
    func pauseTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    func readProgress() {
        progress.accept(0)
        trackProgressSlider.setValue(0, animated: false)
        updateProgressTimer()
    }
    
    // MARK: Read progress continously until value is 100
    @objc func updateTimer(_ timer: Timer) {
        bluejay.read(from: PlaylistService.progressOfPath) { (result: ReadResult<String>) in
            switch result {
            case .success(let value):
                let float = Float(value) ?? 0
                print("Progress \(float)")
                self.progress.accept(float)
                if float == 100 {
                    self.lastProgress = 100
                }
                if float < self.lastProgress {
                    /// value is resetted
                    if self.lastProgress == 100 && float == 0 {
                        defer {
                            /// call after we update the UI completely ( change track , reset to play track number 1)
                            self.readProgress()
                        }
                        self.progress.accept(0)
                        self.lastProgress = 0
                        if self.timer != nil {
                            self.timer?.invalidate()
                            self.timer = nil
                        }
                        if self.index < self.tracks.count - 1 {
                            let indexToPlay = self.index + 1
                            print("auto play \(indexToPlay)")
                            self.showTrack(at: indexToPlay)
                        } else {
                            let indexToPlay = 0
                            self.showTrack(at: indexToPlay)
                        }
                    } else {
                        
                        self.lastProgress = float
                    }
                    
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
