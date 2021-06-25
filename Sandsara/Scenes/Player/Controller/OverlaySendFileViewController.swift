//
//  OverlayViewController.swift
//  Sandsara
//
//  Created by Tín Phan on 05/02/2021.
//

import UIKit

class OverlaySendFileViewController: BaseViewController<NoInputParam> {
    
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var syncProgressBar: UIProgressView!
    @IBOutlet weak var remainTrackCountLabel: UILabel!
    
    var notSyncedTracks = [DisplayItem]()
    
    var isFirmwareUpdate = false
    
    var version = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData(_:)), name: reloadNoti, object: nil)
        let completion = BlockOperation {
            print("All track synced is done")
        }
        
        // MARK: Firmware update mode
        if isFirmwareUpdate {
            let item = notSyncedTracks.first ?? DisplayItem()
            let operation = FileSyncManager.shared.queueDownload(item: item)
            FileSyncManager.shared.triggerOperation(id: item.trackId)
            completion.addDependency(operation)
            completion.cancel()
            OperationQueue.main.addOperation(completion)
            
        } else {
            // MARK: Sync track mode
            for track in self.notSyncedTracks {
                let operation = FileSyncManager.shared.queueDownload(item: track)
                FileSyncManager.shared.triggerOperation(id: track.trackId)
                completion.addDependency(operation)
            }
            
            completion.cancel()
            OperationQueue.main.addOperation(completion)
        }
        
    }
    

    @objc func reloadData(_ noti: Notification) {
        // MARK: Get current sync item in queue and update it on UI
        func getCurrentSyncTask(item: DisplayItem) {
            if let task = FileSyncManager.shared.findCurrentQueue(item: item) {
                self.syncProgressBar.isHidden = false
                self.trackNameLabel.text = self.isFirmwareUpdate ? item.fileName : item.title
                self.remainTrackCountLabel.text = self.isFirmwareUpdate ? "Firmware is updating" :  "\(FileSyncManager.shared.operations.count) tracks are syncing now"
                task.progress
                    .bind(to: self.syncProgressBar.rx.progress)
                    .disposed(by: task.disposeBag)
            } else {
                syncProgressBar.isHidden = true
            }
        }
        
        if let noti = noti.object as? [String: Any], let item = noti["item"] as? DisplayItem {
            getCurrentSyncTask(item: item)
        } else {
            DispatchQueue.main.async {
                self.dismiss(animated: false, completion: {
                    
                    if PlayerViewController.shared.playlingState == .showOnly {
                        /// if user want to add track to queue only, just need to show the success popup for user
                        /// This state need to be reset to .track to keep the correct playling sequence
                        PlayerViewController.shared.playlingState = .track
                        if !self.isFirmwareUpdate {
                            self.showSuccessHUD(message: "Track \(self.notSyncedTracks.first?.title ?? "") was added")
                        } else {
                            /// Action after firmware update is success
                            self.showSuccessHUD(message: "Firmware update successful. The board is restarting ")
                            DeviceServiceImpl.shared.restart()
                        }
                    }
                    if !self.isFirmwareUpdate {
                        // if user want to add track to queue and then play the new track, please call createPlaylist
                        PlayerViewController.shared.createPlaylist()
                    }
                    (UIApplication.topViewController()?.tabBarController?.popupBar.customBarViewController as? PlayerBarViewController)?.state = .haveTrack(displayItem: DeviceServiceImpl.shared.currentTracks[DeviceServiceImpl.shared.currentTrackIndex])
                })
            }
        }
    }
}
