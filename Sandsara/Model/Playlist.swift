//
//  Playlist.swift
//  Sandsara
//
//  Created by Tín Phan on 14/11/2020.
//

import RealmSwift

class PlaylistsResponse: Decodable {
    var playlists: [PlaylistResponse] = []

    enum CodingKeys: String, CodingKey {
        case records
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        container.decodeIfPresent([PlaylistResponse].self, forKey: .records, assignTo: &playlists)
    }
}

class PlaylistResponse: Decodable {
    var playlist: Playlist = Playlist()

    enum CodingKeys: String, CodingKey {
        case fields
        case id
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        container.decodeIfPresent(Playlist.self, forKey: .fields, assignTo: &playlist)

        if let id = try container.decodeIfPresent(String.self, forKey: .id) {
            playlist.id = id
        }
    }
}

class Playlist: Codable {
    var id = ""
    var title = ""
    var thumbnail: [Thumbnail]?
    var author = ""

    var names = [String]()
    var trackId = [String]()

    var file: [File]?
    var files: [File]?
    var authors = [String]()

    var tracks = [Track]()

    enum NestedKeys: String, CodingKey {
        case fields
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title = "name"
        case thumbnails
        case author
        case trackId
        case authors
        case names
        case file
        case files
        case tracks
    }

    init() {}

    init(id: String, title: String, thumbnail: [Thumbnail], author: String) {
        self.id = id
        self.title = title
        self.thumbnail = thumbnail
        self.author = author
    }

    required init(from decoder: Decoder) throws {
        let fieldContainer = try decoder.container(keyedBy: CodingKeys.self)
        if let thumbnail = try fieldContainer.decodeIfPresent([Thumbnail].self, forKey: .thumbnails) {
            self.thumbnail = thumbnail
        }
        fieldContainer.decodeIfPresent(String.self, forKey: .id, assignTo: &id)
        fieldContainer.decodeIfPresent(String.self, forKey: .title, assignTo: &title)
        fieldContainer.decodeIfPresent(String.self, forKey: .author, assignTo: &author)

        fieldContainer.decodeIfPresent([String].self, forKey: .names, assignTo: &names)

        fieldContainer.decodeIfPresent([String].self, forKey: .trackId, assignTo: &trackId)

        fieldContainer.decodeIfPresent([String].self, forKey: .authors, assignTo: &authors)

        if let files = try fieldContainer.decodeIfPresent([File].self, forKey: .files) {
            self.files = files
            for i in 0 ..< files.count {
                if let thumbnail = thumbnail?[i] {
                    print(trackId[i])
                    tracks.append(Track(id: i, title: names[i], trackId: trackId[i] ,thumbnail: [thumbnail], author: authors[i], file: files[i]))
                }
            }
        }

        if let file = try fieldContainer.decodeIfPresent([File].self, forKey: .file) {
            self.file = file
        }
    }

    func encode(to encoder: Encoder) throws {
        var nestedContainer = encoder.container(keyedBy: CodingKeys.self)
        try nestedContainer.encode(id, forKey: .id)
        try nestedContainer.encode(title, forKey: .title)
        try nestedContainer.encode(thumbnail, forKey: .thumbnails)
        try nestedContainer.encode(author, forKey: .author)
        try nestedContainer.encode(file, forKey: .file)
        try nestedContainer.encode(files, forKey: .files)
        try nestedContainer.encode(names, forKey: .names)
        try nestedContainer.encode(authors, forKey: .authors)
        try nestedContainer.encode(trackId, forKey: .trackId)
    }
}

class LocalPlaylist: Object {
    @objc dynamic var playlistName: String = ""
    @objc dynamic var thumbnail: String = ""
    @objc dynamic var author: String = ""
    let tracks = List<LocalTrack>()
    required convenience init(playlistName: String, thumbnail: String, author: String = "Sandsara") {
        self.init()
        self.playlistName = playlistName
        self.thumbnail = thumbnail
        self.author = author
    }

    required convenience init(track: DisplayItem) {
        self.init()
        self.playlistName = track.title
        self.author = track.author
        self.thumbnail = track.thumbnail
    }
}

class FavoritePlaylist: Object {
    @objc dynamic var thumbnail: String = ""
    @objc dynamic var author: String = ""
    let tracks = List<LocalTrack>()
    required convenience init(thumbnail: String, author: String = "Sandsara") {
        self.init()
        self.thumbnail = thumbnail
        self.author = author
    }
}

class SyncedTracks: Object {
    let syncedTracks = List<LocalTrack>()
}

class DownloadedTracks: Object {
    let syncedTracks = List<LocalTrack>()
}

class DownloadedPlaylist: Object {
    @objc dynamic var playlistName: String = ""
    @objc dynamic var thumbnail: String = ""
    @objc dynamic var author: String = ""
    @objc dynamic var fileName: String = ""
    @objc dynamic var fileSize: Int64 = 0
    let tracks = List<LocalTrack>()

    required convenience init(track: DisplayItem) {
        self.init()
        self.playlistName = track.title
        self.author = track.author
        self.thumbnail = track.thumbnail
        self.fileName = track.fileName
        self.fileSize = track.fileSize
    }
}


class SyncedPlaylist: Object {
    @objc dynamic var playlistName: String = ""
    @objc dynamic var thumbnail: String = ""
    @objc dynamic var author: String = ""
    @objc dynamic var fileName: String = ""
    @objc dynamic var fileSize: Int64 = 0
    let tracks = List<LocalTrack>()
    
    required convenience init(track: DisplayItem) {
        self.init()
        self.playlistName = track.title
        self.author = track.author
        self.thumbnail = track.thumbnail
        self.fileName = track.fileName
        self.fileSize = track.fileSize
    }
}
