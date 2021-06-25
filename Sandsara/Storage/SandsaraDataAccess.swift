//
//  SandsaraDataAccess.swift
//  Sandsara
//
//  Created by Tín Phan on 22/11/2020.
//

import RxSwift
import RxCocoa

// MARK: - Data cache from server
class SandsaraDataAccess {
    
    /// Get cached recommended tracks
    /// - Returns: Observable collection of cached tracks
    func getLocalRecommendTracks() -> Observable<[Track]?> {
        return Observable.create { observer -> Disposable in
            observer.onNext(Preferences.PlaylistsDomain.recommendTracks)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    /// Store recommended tracks to local cache
    /// - Parameter tracks: recommended tracks
    /// - Returns: Observable(true) if the data is stored successfully
    func saveRecommendedTracks(tracks: [Track]) -> Observable<Bool> {
        return Observable.create { observer -> Disposable in
            Preferences.PlaylistsDomain.recommendTracks = tracks
            observer.onNext(true)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    /// Get cached all tracks
    /// - Returns: Observable collection of all tracks
    func getLocalAllTracks() -> Observable<[Track]?> {
        return Observable.create { observer -> Disposable in
            observer.onNext(Preferences.PlaylistsDomain.allTracks)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    /// Store all tracks to local cache
    /// - Parameter tracks: all tracks
    /// - Returns: Observable(true) if the data is stored successfully
    func saveAllTracks(tracks: [Track]) -> Observable<Bool> {
        return Observable.create { observer -> Disposable in
            Preferences.PlaylistsDomain.allTracks = tracks
            observer.onNext(true)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    /// Get cached all playlist
    /// - Returns: Observable collection of all playlists
    func getAllPlaylists() -> Observable<[Playlist]?> {
        return Observable.create { observer -> Disposable in
            observer.onNext(Preferences.PlaylistsDomain.allRemotePlaylists)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    /// Store all playlists to local cache
    /// - Parameter playlists: all playlists
    /// - Returns: Observable(true) if the data is stored successfully
    func saveAllPlaylists(playlists: [Playlist]) -> Observable<Bool> {
        return Observable.create { observer -> Disposable in
            Preferences.PlaylistsDomain.allRemotePlaylists = playlists
            observer.onNext(true)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    /// Get cached recommended playlists
    /// - Returns: Observable collection of recommended playlists
    func getRecommendedPlaylists() -> Observable<[Playlist]?> {
        return Observable.create { observer -> Disposable in
            observer.onNext(Preferences.PlaylistsDomain.recommendedPlaylists)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    // Store recommended playlists to local cache
    /// - Parameter playlists: recommended playlists
    /// - Returns: Observable(true) if the data is stored successfully
    func saveRecommendedPlaylists(playlists: [Playlist]) -> Observable<Bool> {
        return Observable.create { observer -> Disposable in
            Preferences.PlaylistsDomain.recommendedPlaylists = playlists
            observer.onNext(true)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    // Store colors from API to local cache
    /// - Parameter colors: colors from API
    /// - Returns: Observable(true) if the data is stored successfully
    func saveColors(colors: [ColorModel]) -> Observable<Bool> {
        return Observable.create { observer -> Disposable in
            Preferences.AppDomain.colors = colors
            observer.onNext(true)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    /// Get cached colors
    /// - Returns: Observable collection of colors
    func getLocalPalettes() -> Observable<[ColorModel]?> {
        return Observable.create { observer -> Disposable in
            observer.onNext(Preferences.AppDomain.colors)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    // Store firmwares from API to local cache
    /// - Parameter colors: firmwares from API
    /// - Returns: Observable(true) if the data is stored successfully
    func saveFirmwares(firmwares: [Firmware]) -> Observable<Bool> {
        return Observable.create { observer -> Disposable in
            Preferences.AppDomain.firmware = firmwares
            observer.onNext(true)
            observer.onCompleted()
            return Disposables.create()
        }
    }

    /// Get cached firmwares
    /// - Returns: Observable collection of firmwares
    func getLocalFirmwares() -> Observable<[Firmware]?> {
        return Observable.create { observer -> Disposable in
            observer.onNext(Preferences.AppDomain.firmware)
            observer.onCompleted()
            return Disposables.create()
        }
    }
}

