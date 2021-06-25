//
//  DownloadQueue.swift
//  Sandsara
//
//  Created by Tín Phan on 17/12/2020.
//

import Foundation
import UIKit

let reloadNoti = Notification.Name("reload")

class AsynchronousOperation: Operation {

    /// State for this operation.

    @objc private enum OperationState: Int {
        case ready
        case executing
        case finished
    }

    /// Concurrent queue for synchronizing access to `state`.

    private let stateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".rw.state", attributes: .concurrent)

    /// Private backing stored property for `state`.

    private var rawState: OperationState = .ready

    /// The state of the operation

    @objc private dynamic var state: OperationState {
        get { return stateQueue.sync { rawState } }
        set { stateQueue.sync(flags: .barrier) { rawState = newValue } }
    }

    // MARK: - Various `Operation` properties

    open         override var isReady:        Bool { return state == .ready && super.isReady }
    public final override var isExecuting:    Bool { return state == .executing }
    public final override var isFinished:     Bool { return state == .finished }

    // KVO for dependent properties

    open override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        if ["isReady", "isFinished", "isExecuting"].contains(key) {
            return [#keyPath(state)]
        }

        return super.keyPathsForValuesAffectingValue(forKey: key)
    }

    // Start

    public final override func start() {
        if isCancelled {
            finish()
            return
        }

        state = .executing

        main()
    }

    /// Subclasses must implement this to perform their work and they must not call `super`. The default implementation of this function throws an exception.

    open override func main() {
        fatalError("Subclasses must implement `main`.")
    }

    /// Call this function to finish an operation that is currently executing

    public func finish() {
        if !isFinished { state = .finished }
    }
}


/// Manager of asynchronous download `Operation` objects

class DownloadManager: NSObject {

    /// Dictionary of operations, keyed by the `taskIdentifier` of the `URLSessionTask`
    fileprivate var operations = [Int: DownloadOperation]()

    static let shared = DownloadManager()

    /// Serial OperationQueue for downloads

    private let queue: OperationQueue = {
        let _queue = OperationQueue()
        _queue.name = "download"
        _queue.maxConcurrentOperationCount = 4   // I'd usually use values like 3 or 4 for performance reasons, but OP asked about downloading one at a time

        return _queue
    }()

    /// Delegate-based `URLSession` for DownloadManager

    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()

    /// Add download
    ///
    /// - parameter URL:  The URL of the file to be downloaded
    ///
    /// - returns:        The DownloadOperation of the operation that was queued

    @discardableResult
    func queueDownload(_ url: URL, item: DisplayItem) -> DownloadOperation {
        let operation = DownloadOperation(session: session, url: url, item: item)
        operations[operation.task.taskIdentifier] = operation
        queue.addOperation(operation)
        return operation
    }

    /// Cancel all queued operations

    func cancelAll() {
        queue.cancelAllOperations()
    }

}

// MARK: URLSessionDownloadDelegate methods

extension DownloadManager: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        operations[downloadTask.taskIdentifier]?.urlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        operations[downloadTask.taskIdentifier]?.urlSession(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }
}

// MARK: URLSessionTaskDelegate methods

extension DownloadManager: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)  {
        let key = task.taskIdentifier
        operations[key]?.urlSession(session, task: task, didCompleteWithError: error)
        operations.removeValue(forKey: key)
    }
}

/// Asynchronous Operation subclass for downloading

import RxSwift
import RxCocoa

class DownloadOperation : AsynchronousOperation {
    let task: URLSessionTask

    let item: DisplayItem

    let progress = BehaviorRelay<Float>(value: 0)

    let disposeBag = DisposeBag()

    var filePath: URL?

    init(session: URLSession, url: URL, item: DisplayItem) {
        self.item = item
        task = session.downloadTask(with: url)
        super.init()
    }

    override func cancel() {
        task.cancel()
        super.cancel()
    }

    override func main() {
        task.resume()
    }
}

// MARK: NSURLSessionDownloadDelegate methods

extension DownloadOperation: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard
            let httpResponse = downloadTask.response as? HTTPURLResponse,
            200..<300 ~= httpResponse.statusCode
        else {
            // handle invalid return codes however you'd like
            return
        }

        do {
            print("\(item.fileName) was downloaded successful")
            let manager = FileManager.default
            let destinationURL = try manager
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent(downloadTask.originalRequest!.url!.lastPathComponent)
            try? manager.removeItem(at: destinationURL)
            try manager.moveItem(at: location, to: destinationURL)

            print("File URL \(destinationURL)")
            filePath = destinationURL
            if !item.isFile {
            DispatchQueue.main.async {
            if self.item.isPlaylist {
            let completion = BlockOperation {
            print("all done")
            }
            
            DispatchQueue.main.async {
            _ = DataLayer.createDownloaedPlaylist(playlist: self.item)
            }
            
            for track in self.item.tracks {
				let name = track.fileName; let size = track.fileSize; let urlString = track.fileURL;
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
            } else {
            _ = DataLayer.addDownloadedTrack(self.item)
            }
            NotificationCenter.default.post(name: reloadNoti, object: self)
            }
            }

        } catch {
            print(error)
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(item.fileSize)
        self.progress.accept(progress)
        print("\(downloadTask.originalRequest!.url!.absoluteString) \(progress)")
    }
}

// MARK: URLSessionTaskDelegate methods

extension DownloadOperation: URLSessionTaskDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)  {
        defer { finish() }

        if let error = error {
            print(error)
            return
        }

        // do whatever you want upon success
    }

}
