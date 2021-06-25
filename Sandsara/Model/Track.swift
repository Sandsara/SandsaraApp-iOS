//
//  Track.swift
//  Sandsara
//
//  Created by Tín Phan on 14/11/2020.
//

import Foundation
import RealmSwift

class Thumbnail: Codable {
    var filename = ""
    var url = ""
var size: Int64 = 0
}

class File: Codable {
    var id = ""
    var url = ""
    var filename = ""
    var size: Int64 = 0
    var type = ""

    enum CodingKeys: String, CodingKey {
        case id
        case url
        case filename
        case size
        case type
    }

    init() {}

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        container.decodeIfPresent(String.self, forKey: .id, assignTo: &id)
        container.decodeIfPresent(String.self, forKey: .url, assignTo: &url)
        container.decodeIfPresent(String.self, forKey: .filename, assignTo: &filename)
        container.decodeIfPresent(String.self, forKey: .type, assignTo: &type)
        container.decodeIfPresent(Int64.self, forKey: .size, assignTo: &size)
    }

    func encode(to encoder: Encoder) throws {
        var nestedContainer = encoder.container(keyedBy: CodingKeys.self)
        try nestedContainer.encode(id, forKey: .id)
        try nestedContainer.encode(url, forKey: .url)
        try nestedContainer.encode(filename, forKey: .filename)
        try nestedContainer.encode(type, forKey: .type)
        try nestedContainer.encode(size, forKey: .size)
    }
}

class TracksResponse: Decodable {
    var tracks: [TrackResponse] = []

    enum CodingKeys: String, CodingKey {
        case records
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        container.decodeIfPresent([TrackResponse].self, forKey: .records, assignTo: &tracks)
    }
}

class TrackResponse: Decodable {
    var playlist: Track = Track()

    enum CodingKeys: String, CodingKey {
        case fields
        case id
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        container.decodeIfPresent(Track.self, forKey: .fields, assignTo: &playlist)

        if let id = try container.decodeIfPresent(String.self, forKey: .id) {
            playlist.trackId = id
        }
    }
}


class Track: Codable {
    var trackId = ""
    var id = 0
    var title = ""
    var thumbnail: [Thumbnail]?
    var author = ""
    var file: [File]?

    enum CodingKeys: String, CodingKey {
        case trackId = "id"
        case id = "trackNumber"
        case title = "name"
        case thumbnail
        case author
        case file
    }

    init() {} 

    init(id: Int, title: String, trackId: String ,thumbnail: [Thumbnail]?, author: String, file: File?) {
        self.id = id
        self.title = title
        self.thumbnail = thumbnail
        self.author = author
        self.file = [file ?? File()]
        self.trackId = trackId
    }

    required init(from decoder: Decoder) throws {
        let fieldContainer = try decoder.container(keyedBy: CodingKeys.self)
        if let id = try? fieldContainer.decodeIfPresent(String.self, forKey: .trackId) {
            self.trackId = id
        }
        fieldContainer.decodeIfPresent(Int.self, forKey: .id, assignTo: &id)
        fieldContainer.decodeIfPresent(String.self, forKey: .title, assignTo: &title)
        fieldContainer.decodeIfPresent(String.self, forKey: .author, assignTo: &author)

        if let thumbnail = try fieldContainer.decodeIfPresent([Thumbnail].self, forKey: .thumbnail) {
            self.thumbnail = thumbnail
        }

        if let file = try fieldContainer.decodeIfPresent([File].self, forKey: .file) {
            self.file = file
        }
    }

    func encode(to encoder: Encoder) throws {
        var nestedContainer = encoder.container(keyedBy: CodingKeys.self)
        try nestedContainer.encode(id, forKey: .id)
        try nestedContainer.encode(trackId, forKey: .trackId)
        try nestedContainer.encode(title, forKey: .title)
        try nestedContainer.encode(thumbnail, forKey: .thumbnail)
        try nestedContainer.encode(author, forKey: .author)
        try nestedContainer.encode(file, forKey: .file)
    }
}

class LocalTrack: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var author: String = ""
    @objc dynamic var thumbnail: String = ""
    @objc dynamic var id: Int = 0
    @objc dynamic var dateModified: Date = Date()
    @objc dynamic var fileName: String = ""
    @objc dynamic var fileSize: Int64 = 0
    @objc dynamic var trackId: String = ""
    @objc dynamic var thumbNailfileName: String = ""
    @objc dynamic var thumbNailfileSize: Int64 = 0



    required convenience init(track: Track) {
        self.init()
        self.title = track.title
        self.author = track.author
        self.thumbnail = track.thumbnail?.first?.url ?? ""
        self.id = track.id
        self.dateModified = Date()
        self.fileName = track.file?.first?.filename ?? ""
        self.fileSize = track.file?.first?.size ?? 0
        self.trackId = track.trackId
    self.thumbNailfileName = track.thumbnail?.first?.filename ?? ""
    self.thumbNailfileSize = track.thumbnail?.first?.size ?? 0
    
    }

    required convenience init(track: DisplayItem) {
        self.init()
        self.title = track.title
        self.author = track.author
        self.thumbnail = track.thumbnail
        self.id = track.id
        self.dateModified = Date()
        self.fileName = track.fileName
        self.trackId = track.trackId
        self.fileSize = track.fileSize
    self.thumbNailfileName = track.thumbNailfileName
    self.thumbNailfileSize = track.thumbNailfileSize
    }
}
