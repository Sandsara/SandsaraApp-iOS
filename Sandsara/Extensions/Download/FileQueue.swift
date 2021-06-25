//
//  FileQueue.swift
//  Sandsara
//
//  Created by Tín Phan on 20/12/2020.
//

import Foundation
import RxSwift
import RxCocoa
import Bluejay

class FileSyncManager: NSObject {

    var cachedTime = 0.0

    private let disposeBag = DisposeBag()

    /// Dictionary of operations, keyed by the `taskIdentifier` of the `URLSessionTask`
    var operations = [String: FileOperation]()
    /// Serial OperationQueue for downloads

    static let shared = FileSyncManager()

    private let queue: OperationQueue = {
        let _queue = OperationQueue()
        _queue.name = "file"
        _queue.maxConcurrentOperationCount = 1    // I'd usually use values like 3 or 4 for performance reasons, but OP asked about downloading one at a time

        return _queue
    }()


    @discardableResult
    func queueDownload(item: DisplayItem) -> FileOperation {
        let operation = FileOperation(item: item)
        operation.delegate = self
        operations[operation.item.trackId] = operation
        return operation
    }

    /// Cancel all queued operations

    func cancelAll() {
        queue.cancelAllOperations()
    }

    func findCurrentQueue(item: DisplayItem) -> FileOperation? {
        return operations.filter {
            $0.value.item.trackId == item.trackId
        }.first?.value
    }

    func getCurrentTimeRunning() -> Observable<TimeInterval>? {
        guard let firstItem = operations.first?.value else { return nil }
        return firstItem.seconds
            .flatMap { value in
                return self.getAfterObservable(before: value, self.cachedTime)
            }.asObservable()
    }

    func getAfterObservable(before: TimeInterval, _ value: TimeInterval) -> Observable<TimeInterval> {
        return Observable.of(before + value)
    }

    func triggerOperation(id: String) {
        guard let currentOperation = operations[id] else { return }
        FileServiceImpl.shared.checkFileExistOnSDCard(name: currentOperation.item.fileName) { isExisted in
            if isExisted {
                self.queue.cancelAllOperations()
                self.updateTrack(item: currentOperation.item)
            } else {
                if self.queue.operations.isEmpty || self.queue.operations.first?.isCancelled ?? false {
                    self.queue.addOperation(currentOperation)
                    NotificationCenter.default.post(name: reloadNoti, object: ["item" : currentOperation.item])
                    currentOperation.startSendFile()
                }
            }
        }
    }
}

extension FileSyncManager: RemoveTask {
    func removeTask(id: String) {
        if operations.count > 0 {
            operations.removeValue(forKey: id)
        }
        if operations.isEmpty {
            print("Queue is empty")
            queue.operations.first?.cancel()
            DispatchQueue.main.async {
                self.queue.operations.first?.cancel()
                NotificationCenter.default.post(name: reloadNoti, object: nil)
                (UIApplication.topViewController()?.tabBarController?.popupBar.customBarViewController as? PlayerBarViewController)?.state = .haveTrack(displayItem: DeviceServiceImpl.shared.currentTracks[DeviceServiceImpl.shared.currentTrackIndex])
            }
        } else {
            guard let nextTask = operations.first?.value else { return }
            queue.addOperation(nextTask)
            NotificationCenter.default.post(name: reloadNoti, object: ["item" : nextTask.item])
            nextTask.startSendFile()
        }
    }

    func updateTrack(item: DisplayItem) {
        defer {
            self.removeTask(id: item.trackId)
        }
        if !item.isFile {
            if item.isPlaylist {
                if DataLayer.createSyncedPlaylist(playlist: item) {
                }
            } else {
                if !DataLayer.addSyncedTrack(item) {
                }
            }
        }
        
    }
}

protocol RemoveTask: class {
    func removeTask(id: String)
    func updateTrack(item: DisplayItem)
}

class FileOperation: AsynchronousOperation {
    var item: DisplayItem
    let progress = BehaviorRelay<Float>(value: 0)
    let seconds = BehaviorRelay<TimeInterval>(value: 0)

    weak var delegate: RemoveTask?

    let disposeBag = DisposeBag()

    init(item: DisplayItem) {
        self.item = item
    }

    func startSendFile() {
        start()
        let start = CFAbsoluteTimeGetCurrent()
        bluejay.run { sandsaraBoard -> Bool in
            if let bytes: [[UInt8]] = self.getFile(file: self.item.fileName) {
                do {
                    try sandsaraBoard.write(to: FileService.sendFileFlag, value: self.item.fileName)
                    for i in 0 ..< bytes.count {
                        let start1 = CFAbsoluteTimeGetCurrent()
                        try sandsaraBoard.writeAndListen(writeTo: FileService.sendBytes, value: Data(bytes: bytes[i], count: bytes[i].count), listenTo: FileService.sendBytes, completion: { (result: UInt8) -> ListenAction in
                            let diff = CFAbsoluteTimeGetCurrent() - start1
                            print("Send chunks took \(diff) seconds")
                            self.progress.accept(Float(i) / Float(bytes.count))
                            print("Progress \(Float(i) / Float(bytes.count))")
                            self.seconds.accept(diff)
                            return .done
                        })
                    }
                } catch(let error) {
                    debugPrint(error.localizedDescription)
                }
                return false
            }
            return false
        } completionOnMainThread: { result in
            switch result {
            case .success:
                bluejay.write(to: FileService.sendFileFlag, value: self.item.fileName) { result in
                    switch result {
                    case .success:
                    debugPrint("Send file success")
                    let diff = CFAbsoluteTimeGetCurrent() - start
                    self.seconds.accept(diff)
                    print("Took \(diff) seconds")
                    let track = self.item
                    self.delegate?.updateTrack(item: track)
                    self.cancel()
                    case .failure(let error):
                        debugPrint("Send file error \(error.localizedDescription)")
                        self.cancel()
                    
                    }
                }
            case .failure:
                self.finish()
                debugPrint("send error")
            }
        }
    }


    override func cancel() {
      //  delegate?.removeTask(id: item.trackId)
        super.cancel()
    }

    override func main() {
    }

    override func finish() {
      //  delegate?.removeTask(id: item.trackId)
    }

    func getFile(file: String) -> [[UInt8]]? {
        var chunks = [[UInt8]]()
        // See if the file exists.
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent(file) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                if let stream = InputStream(fileAtPath: filePath) {
                    var buf = [UInt8](repeating: 0, count: 512)
                    stream.open()

                    while case let amount = stream.read(&buf, maxLength: 512), amount > 0 {
                        chunks.append(Array(buf[..<amount]))
                    }
                    stream.close()
                }
            }
        }
        return chunks
    }
}
