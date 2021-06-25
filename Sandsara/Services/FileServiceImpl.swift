//
//  FileServiceImpl.swift
//  Sandsara
//
//  Created by Tín Phan on 30/11/2020.
//

import Foundation
import Bluejay
import RxCocoa
import RxSwift

class FileServiceImpl {
    static let shared = FileServiceImpl()

    let seconds = PublishRelay<TimeInterval>()

    let sendSuccess = PublishRelay<Bool>()

    let fileExist = PublishRelay<Bool>()

    var chunks = [Int]()

    var originChunks = [Int]()

    let disposeBag = DisposeBag()

    
    /// Read file function
    /// - Parameter filename: name of file want to read for example, Sandsara001.bin
    func readFile(filename: String) {
        fileExist.accept(false)
        let start = CFAbsoluteTimeGetCurrent()
        bluejay.run { sandsaraBoard -> Bool in
            var resultFiles = ""
            do {
                try sandsaraBoard.write(to: FileService.readFileFlag, value: filename)
                try sandsaraBoard.listen(to: FileService.receiveFileRespone, completion: {
                    (result: String) -> ListenAction in
                    resultFiles = result
                    if result == "-1" || result == "-2" {
                        self.fileExist.accept(false)
                        return .done
                    }
                    if result == "done" {
                        self.fileExist.accept(true)
                        return .done
                    }
                    return .keepListening
                })
            }

            if resultFiles == "ok" {
                let bytes: String = try sandsaraBoard.read(from: FileService.readFiles)
                let intBytes = Int(bytes) ?? 0
                print("total bytes \(intBytes)")
            }

            return resultFiles == "-1" || resultFiles == "-2" || resultFiles == "done"
        } completionOnMainThread: { result in
            switch result {
            case .success:
                self.fileExist.subscribeNext {
                    if $0 {
                        debugPrint("File exist")
                    }
                }.disposed(by: self.disposeBag)
            case .failure:
                debugPrint("send error")
            }
        }
    }

    
    /// Send file function
    /// - Parameters:
    ///   - fileName: fileName , for example the name is Sandsara001
    ///   - extensionName: fileExtension, for example the extension is bin
    ///   - isPlaylist: can put by false or skip
    func sendFiles(fileName: String,
                   extensionName: String, isPlaylist: Bool = false) {
        // reset value
        sendSuccess.accept(false)
        fileExist.accept(false)
        let start = CFAbsoluteTimeGetCurrent()
        bluejay.run { sandsaraBoard -> Bool in
            if let bytes: [[UInt8]] = self.getFile(forResource: fileName, withExtension: extensionName, isPlaylist: isPlaylist) {
                self.originChunks = [Int].init(repeating: 0, count: bytes.count)
                do {
                    try sandsaraBoard.write(to: FileService.sendFileFlag, value: "\(fileName).\(extensionName)")
                    for i in 0 ..< bytes.count {
                        try sandsaraBoard.writeAndListen(writeTo: FileService.sendBytes, value: Data(bytes: bytes[i], count: bytes[i].count), listenTo: FileService.sendBytes, completion: { (result: UInt8) -> ListenAction in
                            let start1 = CFAbsoluteTimeGetCurrent()
                            let diff = CFAbsoluteTimeGetCurrent() - start1
                            print("Send chunks took \(diff) seconds")
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
                self.fileExist.subscribeNext {
                    if $0 {
                        debugPrint("File exist")
                    }
                }.disposed(by: self.disposeBag)

                bluejay.write(to: FileService.sendFileFlag, value: "\(fileName).\(extensionName)") { result in
                    switch result {
                    case .success:
                        debugPrint("Send file success")
                        let diff = CFAbsoluteTimeGetCurrent() - start
                        print("Took \(diff) seconds")
                        self.seconds.accept(diff)
                        self.sendSuccess.accept(true)
                    case .failure(let error):
                        self.sendSuccess.accept(false)
                        debugPrint("Send file error \(error.localizedDescription)")
                    }
                }
            case .failure:
                debugPrint("send error")
            }
        }
    }
    
    
    /// Convert file to array of 512 chunk of bytes
    /// - Parameters:
    ///   - resource: fileName , for example the name is Sandsara001
    ///   - fileExt: fileExtension, for example the extension is bin
    ///   - isPlaylist: can put by false or skip
    /// - Returns: array of 512 chunk of bytes
    func getFile(forResource resource: String,
                 withExtension fileExt: String?, isPlaylist: Bool = false) -> [[UInt8]]? {
        var chunks = [[UInt8]]()
        // See if the file exists.
        var filePath = ""

        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("\(resource).\(fileExt ?? "")") {
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

    /// Create a file to send to SD Card
    func createOrOverwriteEmptyFileInDocuments(filename: String) {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            debugPrint("ERROR IN createOrOverwriteEmptyFileInDocuments")
            return
        }
        let fileURL = dir.appendingPathComponent(filename)
        do {
            try "".write(to: fileURL, atomically: true, encoding: .utf8)
        }
        catch {
            debugPrint("ERROR WRITING STRING: " + error.localizedDescription)
        }
        debugPrint("FILE CREATED: " + fileURL.absoluteString)
    }
    
    /// Write string line by line to a file
    func writeString(string: String, fileHandle: FileHandle){
        let data = string.data(using: String.Encoding.utf8)
        guard let dataU = data else {
            debugPrint("ERROR WRITING STRING: " + string)
            return
        }
        fileHandle.seekToEndOfFile()
        fileHandle.write(dataU)
    }

    /// Read file by fileName
    private func readFile(filename: String) -> String? {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            debugPrint("ERROR OPENING FILE")
            return nil
        }
        let fileURL = dir.appendingPathComponent(filename)

        return fileURL.absoluteString
    }
    
    /// Check if file is on Document Directory or not
    func existingFile(fileName: String) -> (Bool, UInt64) {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("\(fileName)") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                if let size = getSizeOfFile(withPath: filePath) {
                    return (true, size)
                }
                return (true, 0)
            } else {
                return (false, 0)
            }
        } else {
            return (false, 0)

        }
    }
    
    /// Get file size
    private func getSizeOfFile(withPath path:String) -> UInt64? {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: path)
            if let fileSize = fileAttributes[FileAttributeKey.size]  {
                return (fileSize as! NSNumber).uint64Value
            } else {
                print("Failed to get a size attribute from path: \(path)")
            }
        } catch {
            print("Failed to get file attributes for local path: \(path) with error: \(error)")
        }
        return 0
    }

    func getHandleForFileInDocuments(filename: String)->FileHandle? {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            debugPrint("ERROR OPENING FILE")
            return nil
        }
        let fileURL = dir.appendingPathComponent(filename)
        do {
            let fileHandle: FileHandle? = try FileHandle(forWritingTo: fileURL)
            return fileHandle
        }
        catch {
            debugPrint("ERROR OPENING FILE: " + error.localizedDescription)
            return nil
        }
    }
    
    
    /// Update playlist playing behavior
    /// - Parameters:
    ///   - fileName: playlistName
    ///   - index: index of a track in playlist
    ///   - mode: if mode is .playlist, will overwrite current playing playlist to the new playlist, else update the path position
    func updatePlaylist(fileName: String, index: Int, mode: PlayingState = .playlist, completionHandler: @escaping ((Bool) -> ())) {
        bluejay.run { sandsaraBoard -> Bool in
            do {
                if mode == .playlist {
                    try sandsaraBoard.write(to: PlaylistService.playlistName, value: fileName)
                }
                try sandsaraBoard.write(to: PlaylistService.pathPosition, value: "\(index)")
            } catch(let error) {
                print(error.localizedDescription)
            }
            return false
        } completionOnMainThread: { result in
            switch result {
            case .success:
             //   DeviceServiceImpl.shared.readPlaylistValue()
                completionHandler(true)
            case .failure(let error):
                debugPrint(error.localizedDescription)
                completionHandler(false)
            }
        }
    }
    
    
    /// Check if file is existed on SD Card
    /// - Parameters:
    ///   - name: fileName
    ///   - completionHandler:
    /// - Returns: true if file is existed
    func checkFileExistOnSDCard(name: String, completionHandler: @escaping ((Bool) -> ())) {
        bluejay.write(to: FileService.checkFileExist, value: name) { result in
            switch result {
            case .success:
                bluejay.read(from: FileService.receiveFileRespone) { (result: ReadResult<String>) in
                    switch result {
                    case .success(let value):
                        completionHandler(value == "1")
                        print("Status \(value.debugDescription)")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    
    /// Update track by index
    /// - Parameters:
    ///   - index: pass the index of track you want to play
    func updatePositionIndex(index: Int, completionHandler: @escaping ((Bool) -> ())) {
        bluejay.write(to: PlaylistService.pathPosition, value: "\(index)") { result in
            switch result {
            case .success:
                debugPrint("Play success")
                completionHandler(true)
            case .failure(let error):
                debugPrint("Play update track error")
                completionHandler(false)
            }
        }
    }

}
