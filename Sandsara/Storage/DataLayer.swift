//
//  DataLayer.swift
//  Sandsara
//
//  Created by Tín Phan on 15/11/2020.
//

import RealmSwift
import RxSwift


// MARK: - Realm Datalayer
class DataLayer {
    /// Shared instance to use all the app
    static let shareInstance = DataLayer()
    
    /// Realm Stack Initial
    static let realm = try? Realm()

    /// Realm Schema Version
    private let schemaVersion: UInt64 = 6

    // MARK: Function to run migration for local database when we add the new field to Realm Object
    func config() {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: schemaVersion,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < self.schemaVersion) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
            })

        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
    
    // MARK: Realm Write function
    public static func write(realm: Realm, writeClosure: () -> ()) {
        do {
            try realm.write {
                writeClosure()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: Create user's local playlist
    
    /// Create user's local playlist
    /// - Parameters:
    ///   - name: playlist name
    ///   - thumbnail: first thumbnail url
    ///   - author: author of the track
    /// - Returns: true if the playlist is added successfully
    static func createPlaylist(name: String, thumbnail: String, author: String) -> Bool {
        guard let realm = realm else { return false }
        if realm.objects(LocalPlaylist.self).filter("playlistName == '\(name)'").first != nil {
            return false
        } else {
            let playlist = LocalPlaylist(playlistName: name,
                                         thumbnail: thumbnail,
                                         author: author)
            write(realm: realm, writeClosure: {
                realm.add(playlist)
            })

            return true
        }
    }
    
    // MARK: Function to add a track to user's local playlist
    
    /// add a track to user's local playlist
    /// - Parameters:
    ///   - name: playlist name
    ///   - track: Local track user want to add into playlist
    /// - Returns: return true if the track is added successfully
    static func addTrackToPlaylist(name: String, track: LocalTrack) -> Bool  {
        if let object = realm?.objects(LocalPlaylist.self).filter("playlistName == '\(name)'").first {
            for savedTrack in object.tracks {
                if savedTrack.trackId == track.trackId {
                    return false
                } else {
                    continue
                }
            }
            write(realm: realm!, writeClosure: {
                object.tracks.append(track)
            })
            return true
        }
        return false
    }
    
    // MARK: Function to add a track to user's favorite playlist
    
    /// add a track to user's favorite playlist
    /// - Parameter favoriteTrack: a track user want to add to Favorite playlist
    /// - Returns: false if the track is not existed
    static func addTrackToFavoriteList(_ favoriteTrack: LocalTrack) -> Bool {
        var isExisted: Bool = false
        if let favList = realm?.objects(FavoritePlaylist.self).first {
            for track in favList.tracks {
                if track.trackId == favoriteTrack.trackId && !track.isInvalidated {
                    isExisted = true
                    break
                } else {
                    continue
                }
            }
            if isExisted == false {
                write(realm: realm!, writeClosure: {
                    favList.tracks.append(favoriteTrack)
                })
            }
        } else {
            let list = FavoritePlaylist(thumbnail: favoriteTrack.thumbnail)
            write(realm: realm!, writeClosure: {
                realm?.add(list)
            })
            write(realm: realm!, writeClosure: {
                list.tracks.append(favoriteTrack)
            })
        }

        return isExisted
    }
    
    // MARK: Function to remove a track from user's favorite playlist
    
    /// remove a track from user's favorite playlist
    /// - Parameter trackToDelete: a track user want to delete from Favorite playlist
    static func unLikeTrack(_ trackToDelete: LocalTrack) {
        if let favList = realm?.objects(FavoritePlaylist.self).first {
            var isFound = false
            for i in 0 ..< favList.tracks.count {
                if favList.tracks[i].trackId == trackToDelete.trackId && !favList.tracks[i].isInvalidated {
                    isFound = true
                } else { continue }
            }
            if isFound == true {
                var dbTracks = [LocalTrack]()
                for track in favList.tracks {
                    if !track.isInvalidated && track.trackId != trackToDelete.trackId {
                        dbTracks.append(track)
                    }
                }
                write(realm: realm!, writeClosure: {
                    favList.tracks.removeAll()
                    favList.tracks.append(objectsIn: dbTracks)
                })
            }
        }
    }
    
    // MARK: Function to load favorite track from Favorite playlist
    
    /// load favorite track from Favorite playlist
    /// - Parameter dbTrack: a track to check if existed in Favorite playlist
    /// - Returns: true if the track is existed in Favorite playlist
    static func loadFavTrack(_ dbTrack: LocalTrack) -> Bool {
        if let list = realm?.objects(FavoritePlaylist.self).first {
            for track in list.tracks {
                if track.trackId == dbTrack.trackId && !track.isInvalidated {
                    return true
                } else{
                    continue
                }
            }
            return false
        }
        return false
    }
    
    // MARK: Function to load downloaded track from Downloaded playlist
    
    /// load downloaded track from Downloaded playlist
    /// - Parameter dbTrack: a track to check if existed in Downloaded playlist
    /// - Returns: true if the track is existed in Downloaded playlist
    static func loadDownloadedTrack(_ dbTrack: LocalTrack) -> Bool {
        if let list = realm?.objects(DownloadedTracks.self).first {
            for track in list.syncedTracks {
                if track.trackId == dbTrack.trackId && !track.isInvalidated {
                    return true
                } else{
                    continue
                }
            }
            return false
        }
        return false
    }
    
    // MARK: Function to load Favorite playlist
    static func loadFavList() -> FavoritePlaylist? {
        if let list = realm?.objects(FavoritePlaylist.self).first {
            return list
        }
        return nil
    }
    
    // MARK: Function to load tracks of Favorite playlist
    
    /// load tracks of Favorite playlist
    /// - Returns: array of tracks inside Favorite playlist
    static func loadFavTracks() -> [LocalTrack] {
        var tracks = [LocalTrack]()
        if let list = realm?.objects(FavoritePlaylist.self).first {
            let sortedTracks = list.tracks.sorted(byKeyPath: "id", ascending: true)
            for track in sortedTracks {
                if !track.isInvalidated {
                    tracks.append(track)
                }
            }
        }
        return tracks
    }
    
    // MARK: Function to load all user's local playlist
    
    /// load all user's local playlist
    /// - Returns: array of user's local playlist
    static func loadPlaylists() -> [LocalPlaylist] {
        var playlists = [LocalPlaylist]()
        let object = realm?.objects(LocalPlaylist.self)
        for playlist in object! {
            playlists.append(playlist)
        }
        return playlists
    }
    
    // MARK: Function to load tracks of user's local playlist
    
    /// load tracks of user's local playlist
    /// - Parameter name: user playlist's name
    /// - Returns: array of tracks
    static func loadPlaylistTracks(name: String) -> [LocalTrack] {
        var followUsers = [LocalTrack]()
        if let list = realm?.objects(LocalPlaylist.self).filter("playlistName == '\(name)'").first {
            for followUser in list.tracks {
                if !followUser.isInvalidated {
                    followUsers.append(followUser)
                }
            }
        }
        return followUsers
    }
    
    // MARK: Function to delete a track from user's local playlist
    
    /// delete track from user's local playlist
    /// - Parameter name: user playlist's name
    /// - Parameter trackToDelete: track user want to delete
    static func deleteTrackFromPlaylist(_ name: String ,_ trackToDelete: LocalTrack) {
        if let localList = realm?.objects(LocalPlaylist.self).filter("playlistName == '\(name)'").first {
            var isFound = false
            for track in localList.tracks {
                if track.trackId == trackToDelete.trackId && !track.isInvalidated {
                    isFound = true
                }
                else { continue }
            }
            if isFound == true {
                var dbTracks = [LocalTrack]()
                for track in localList.tracks {
                    if !track.isInvalidated && track.trackId != trackToDelete.trackId {
                        dbTracks.append(track)
                    }
                }
                write(realm: realm!, writeClosure: {
                    localList.tracks.removeAll()
                    localList.tracks.append(objectsIn: dbTracks)
                })
            }
        }
    }
    
    // MARK: Function to delete user's local playlist
    
    /// delete user's local playlist
    /// - Parameter name: user playlist's name
    static func deletePlaylist(_ name: String) -> Bool {
        if let object = realm?.objects(LocalPlaylist.self).filter("playlistName == '\(name)'").first {
            write(realm: realm!, writeClosure: {
                object.tracks.removeAll()
                realm?.delete(object)
            })
            return true
        }
        return false
    }
    
    // MARK: Function to check if the track is synced to board or not
    
    /// check if the track is synced to board or not
    /// - Parameter name: track
    /// - Returns: true if the track is synced
    static func checkTrackIsSynced(_ track: DisplayItem) -> Bool {
        guard DeviceServiceImpl.shared.status.value != .unknown else { return false }
        let localTrack = LocalTrack(track: track)

        guard let realm = realm else { return false }
        if let syncedList = realm.objects(SyncedTracks.self).first {
            for track in syncedList.syncedTracks where localTrack.trackId == track.trackId {
                return true
            }
        }
        return false
    }
    
    // MARK: Function to check if the track is synced to board or not
    
    /// check if the track is synced to board or not
    /// - Parameter name: track
    /// - Returns: true if the track is synced
    static func addSyncedTrack(_ track: DisplayItem) -> Bool {
        let localTrack = LocalTrack(track: track)
        guard let realm = realm else { return false }

        var isExisted = false
        if let object = realm.objects(SyncedTracks.self).first {
            for syncedTrack in object.syncedTracks {
                if syncedTrack.trackId == localTrack.trackId {
                    isExisted = true
                    return isExisted
                } else {
                    continue
                }
            }
            write(realm: realm, writeClosure: {
                object.syncedTracks.append(localTrack)
            })
        } else {
            let list = SyncedTracks()
            write(realm: realm, writeClosure: {
                realm.add(list)
            })
            write(realm: realm, writeClosure: {
                list.syncedTracks.append(localTrack)
            })
        }
        return isExisted
    }

    
    // MARK: Function to add a track to user's downloaded playlist
    
    /// add a track to user's downloaded playlist
    /// - Parameter track: a track user want to add to downloaded playlist
    /// - Returns: false if the track is not existed
    static func addDownloadedTrack(_ track: DisplayItem) -> Bool {
        let localTrack = LocalTrack(track: track)
        guard let realm = realm else { return false }
        var isExisted: Bool = false
        if let object = realm.objects(DownloadedTracks.self).first {
            print("Count \(object.syncedTracks.count)")
            for downloadedTrack in object.syncedTracks {
                if track.trackId == downloadedTrack.trackId && !track.trackId.isEmpty {
                    isExisted = true
                    break
                }
            }
            if !isExisted {
                write(realm: realm, writeClosure: {
                    object.syncedTracks.append(localTrack)
                })
            }
        } else {
            let list = DownloadedTracks()
            write(realm: realm, writeClosure: {
                realm.add(list)
            })
            write(realm: realm, writeClosure: {
                list.syncedTracks.append(localTrack)
            })


        }
        return isExisted
    }

    // MARK: Function to create user's downloaded playlist
    
    /// create user's downloaded playlist
    /// - Parameter playlist: a track user want to add to downloaded playlist
    /// - Returns: true
    static func createDownloaedPlaylist(playlist: DisplayItem) -> Bool {
        guard let realm = realm else { return false }
        let playlistToAdd = DownloadedPlaylist(track: playlist)
        let tracks = playlist.tracks.map {
            LocalTrack(track: $0)
        }
        write(realm: realm, writeClosure: {
            realm.add(playlistToAdd)
        })

        write(realm: realm, writeClosure: {
            playlistToAdd.tracks.append(objectsIn: tracks)
        })

        return true
    }
    
    // MARK: Function to load all downloaded tracks
    
    /// load all downloaded track
    /// - Returns: array of tracks
    static func loadDownloadedTracks() -> [LocalTrack] {
        var tracks = [LocalTrack]()
        if let list = realm?.objects(DownloadedTracks.self).first {
            let sortedTracks = list.syncedTracks.sorted(byKeyPath: "id", ascending: true)
            for track in sortedTracks {
                if !track.isInvalidated {
                    tracks.append(track)
                }
            }
        }
        return tracks.unique { $0.trackId }
    }
    
    // MARK: Function to load all downloaded playlists
    
    /// load all downloaded playlists
    /// - Returns: array of playlists
    static func loadDownloaedPlaylists() -> [DownloadedPlaylist] {
        var playlists = [DownloadedPlaylist]()
        if let list = realm?.objects(DownloadedPlaylist.self) {
            for playlist in list {
                playlists.append(playlist)
            }
        }
        return playlists
    }
    
    // MARK: Function to load detail of downloaded playlist
    
    /// load detail of downloaded playlist
    /// - Parameter name: playist name
    /// - Returns: array of track in playlist
    static func loadDownloadedDetailList(name: String) -> [LocalTrack] {
        var tracks = [LocalTrack]()
        if let list = realm?.objects(DownloadedPlaylist.self).filter("playlistName == '\(name)'").first {
            let sortedTracks = list.tracks.sorted(byKeyPath: "id", ascending: true)
            for track in sortedTracks {
                if !track.isInvalidated {
                    tracks.append(track)
                }
            }
        }
        return tracks
    }
    
    // MARK: Function to check playlist is downloaded
    
    /// check playlist is downloaded
    /// - Parameter name: playlist name
    /// - Returns: return true if playlist is downloaded
    static func loadDownloadedDetail(name: String) -> Bool {
        if (realm?.objects(DownloadedPlaylist.self).filter("playlistName == '\(name)'").first) != nil {
            return true
        }

        return false
    }
    
    // MARK: Function to delete downloaded playlist
    
    /// delete downloaded playlist
    /// - Parameter name: playlist name
    /// - Returns: true if playlist is deleted
    static func deleteDownloadedPlaylist(_ name: String) -> Bool {
        if let object = realm?.objects(DownloadedPlaylist.self).filter("playlistName == '\(name)'").first {
            for track in object.tracks {
                let fileName = track.fileName
                let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                let url = NSURL(fileURLWithPath: path)
                if let pathComponent = url.appendingPathComponent("\(fileName)") {
                    let filePath = pathComponent.path
                    let fileManager = FileManager.default
                    if fileManager.fileExists(atPath: filePath) {
                        do {
                            try FileManager.default.removeItem(at: pathComponent)
                        } catch let error as NSError {
                            print("Error: \(error.domain)")
                        }
                    }
                }
            }

            let fileName = object.fileName
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let url = NSURL(fileURLWithPath: path)
            if let pathComponent = url.appendingPathComponent("\(fileName)") {
                let filePath = pathComponent.path
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: filePath) {
                    do {
                        try FileManager.default.removeItem(at: pathComponent)
                    } catch let error as NSError {
                        print("Error: \(error.domain)")
                    }
                }
            }

            defer {
                write(realm: realm!, writeClosure: {
                    object.tracks.removeAll()
                    realm?.delete(object)
                })
            }
            return true
        }
        return false
    }
    
    // MARK: Function to mapping when read data from Sandsara board. If the track is not downloaded, should return a track with default track name on SD Card
    static func loadDownloadedTrack(_ name: String) -> DisplayItem {
        if let list = realm?.objects(DownloadedTracks.self).first {
            for track in list.syncedTracks {
                if track.fileName == name && !track.isInvalidated {
                    return DisplayItem(track: track)
                } else{
                    continue
                }
            }
        }
        if let tracks = Preferences.PlaylistsDomain.allTracks {
            for track in tracks {
                if track.file?.first?.filename == name {
                    return DisplayItem(track: track)
                } else {
                    continue
                }
            }
        }
        return DisplayItem(track: Track(id: 0, title: name, trackId: "", thumbnail: nil, author: name, file: nil))
    }
    
    static func createSyncedPlaylist(playlist: DisplayItem) -> Bool {
        guard let realm = realm else { return false }
        let playlistToAdd = SyncedPlaylist(track: playlist)
        let tracks = playlist.tracks.map {
            LocalTrack(track: $0)
        }
        write(realm: realm, writeClosure: {
            realm.add(playlistToAdd)
        })

        write(realm: realm, writeClosure: {
            playlistToAdd.tracks.append(objectsIn: tracks)
        })

        return true
    }
}


extension Array {
    /// Unique element filter fuction
    func unique<T:Hashable>(map: ((Element) -> (T)))  -> [Element] {
        var set = Set<T>() //the unique list kept in a Set for fast retrieval
        var arrayOrdered = [Element]() //keeping the unique list of elements but ordered
        for value in self {
            if !set.contains(map(value)) {
                set.insert(map(value))
                arrayOrdered.append(value)
            }
        }
        return arrayOrdered
    }
}
