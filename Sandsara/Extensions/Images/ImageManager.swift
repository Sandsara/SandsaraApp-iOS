//
//  ImageManager.swift
//  Sandsara
//
//  Created by Tín Phan on 27/01/2021.
//

import Foundation
import UIKit

extension UIImage {
var topHalf: UIImage? {
guard let cgImage = cgImage, let image = cgImage.cropping(to: CGRect(origin: .zero, size: CGSize(width: size.width, height: size.height/2))) else { return nil }
return UIImage(cgImage: image, scale: scale, orientation: imageOrientation)
}
var bottomHalf: UIImage? {
guard let cgImage = cgImage, let image = cgImage.cropping(to: CGRect(origin: CGPoint(x: 0,  y: CGFloat(Int(size.height)-Int(size.height/2))), size: CGSize(width: size.width, height: CGFloat(Int(size.height) - Int(size.height/2))))) else { return nil }
return UIImage(cgImage: image, scale: scale, orientation: imageOrientation)
}
var leftHalf: UIImage? {
guard let cgImage = cgImage, let image = cgImage.cropping(to: CGRect(origin: .zero, size: CGSize(width: size.width/2, height: size.height))) else { return nil }
return UIImage(cgImage: image, scale: scale, orientation: imageOrientation)
}
var rightHalf: UIImage? {
guard let cgImage = cgImage, let image = cgImage.cropping(to: CGRect(origin: CGPoint(x: CGFloat(Int(size.width)-Int((size.width/2))), y: 0), size: CGSize(width: CGFloat(Int(size.width)-Int((size.width/2))), height: size.height)))
else { return nil }
return UIImage(cgImage: image, scale: scale, orientation: imageOrientation)
}
var splitedInFourParts: [UIImage] {
guard case let topHalf = topHalf,
      case let bottomHalf = bottomHalf,
      let topLeft = topHalf?.leftHalf,
      let topRight = topHalf?.rightHalf,
      let bottomLeft = bottomHalf?.leftHalf,
      let bottomRight = bottomHalf?.rightHalf else{ return [] }
return [topLeft, topRight, bottomLeft, bottomRight]
}
}

class ImageDownloadManager: NSObject {

/// Dictionary of operations, keyed by the `taskIdentifier` of the `URLSessionTask`
fileprivate var operations = [Int: ImageDownloadOperation]()

var images = [UIImage]()

/// Serial OperationQueue for downloads

static let shared = ImageDownloadManager()

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
func queueDownload(_ url: URL) -> ImageDownloadOperation {
let operation = ImageDownloadOperation(session: session, url: url)
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

extension ImageDownloadManager: URLSessionDownloadDelegate {
func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
operations[downloadTask.taskIdentifier]?.urlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
}

func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
operations[downloadTask.taskIdentifier]?.urlSession(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
}
}

// MARK: URLSessionTaskDelegate methods

extension ImageDownloadManager: URLSessionTaskDelegate {
func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)  {
let key = task.taskIdentifier
operations[key]?.urlSession(session, task: task, didCompleteWithError: error)
operations.removeValue(forKey: key)
}
}

/// Asynchronous Operation subclass for downloading

import RxSwift
import RxCocoa

class ImageDownloadOperation : AsynchronousOperation {
let task: URLSessionTask

let disposeBag = DisposeBag()

var filePath: URL?

init(session: URLSession, url: URL) {
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

extension ImageDownloadOperation: URLSessionDownloadDelegate {

func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
guard
let httpResponse = downloadTask.response as? HTTPURLResponse,
200..<300 ~= httpResponse.statusCode
else {
// handle invalid return codes however you'd like
return
}

do {
print("downloaded successful")
let manager = FileManager.default
let destinationURL = try manager
.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
.appendingPathComponent(downloadTask.originalRequest!.url!.lastPathComponent)
try? manager.removeItem(at: destinationURL)
try manager.moveItem(at: location, to: destinationURL)

print("File URL \(destinationURL)")
filePath = destinationURL


} catch {
print(error)
}
}

func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
}
}

// MARK: URLSessionTaskDelegate methods

extension ImageDownloadOperation: URLSessionTaskDelegate {

func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)  {
defer { finish() }

if let error = error {
print(error)
return
}

// do whatever you want upon success
}

}
