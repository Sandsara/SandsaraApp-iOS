//
//  SandsaraDataService.swift
//  Sandsara
//
//  Created by Tín Phan on 22/11/2020.
//

import Moya
import RxSwift
import RxCocoa

let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)

class SandsaraDataServices {
    private var recommendTracks: [Track]?
    private var recommendPlaylists: [Playlist]?
    private var colors: [ColorModel]?
    private var allTracks: [Track]?
    private var allPlaylist: [Playlist]?
    private var playlistDetail: [Track]?
    private var firmware: [Firmware]?

    private let api: SandsaraAPIService
    private let dataAccess: SandsaraDataAccess

    private let disposeBag = DisposeBag()

    init(api: SandsaraAPIService = SandsaraAPIService(apiProvider: MoyaProvider<SandsaraAPI>()),
         dataAccess: SandsaraDataAccess = SandsaraDataAccess()) {
        self.api = api
        self.dataAccess = dataAccess
    }

    func getServicesOption(for apiType: SandsaraAPI) -> ServiceOption {
        guard NetworkingServiceImpl().isConnected else { return .cache }
        switch apiType {
        case .recommendedtracks:
            recommendTracks = Preferences.PlaylistsDomain.recommendTracks
            if recommendTracks != nil {
                return .both
            }
            return .server
        case .alltrack:
            if allTracks != nil {
                return .both
            }
            return .server
        case .recommendedplaylist:
            recommendPlaylists = Preferences.PlaylistsDomain.recommendedPlaylists
            if recommendPlaylists != nil {
                return .both
            }
            return .server
        case .playlists:
            if allPlaylist != nil {
                return .both
            }
            return .server
        case .playlistDetail:
            if playlistDetail != nil {
                return .both
            }
            return .server
        case .colorPalette:
            return Preferences.AppDomain.colors == nil ? .server : .cache
        case .firmware:
            firmware = Preferences.AppDomain.firmware
            if firmware != nil {
                return .both
            }
            return .server
        default:
            return .server
        }
    }

    private func getRecommendedTracksFromServer() -> Observable<[Track]> {
        return api
            .getRecommendTracks()
            .do(onSuccess: { [weak self] tracks in
                guard let self = self else { return }
                self.recommendTracks = tracks
            }).debug()
            .asObservable()
            .flatMap { [weak self] result -> Observable<([Track], Bool)> in
                guard let self = self else { return Observable.just((result, false)) }
                return Observable.combineLatest(Observable.just(result), self.dataAccess.saveRecommendedTracks(tracks: result)) { ($0, $1) }
            }
            .map { (cards, _) -> [Track] in
                return cards
            }
    }

    func getRecommendTracks(option: ServiceOption) -> Observable<[Track]> {
        let serverObservable = getRecommendedTracksFromServer()
        let localObservable = dataAccess
            .getLocalRecommendTracks()
            .compactMap { $0 }
            .doOnNext({ [weak self] cache in
                guard let self = self else { return }
                self.recommendTracks = cache
            })

        switch option {
        case .server:
            return serverObservable
                .subscribeOn(ConcurrentDispatchQueueScheduler(queue: backgroundQueue))
        case .cache:
            if let cardList = self.recommendTracks {
                return Observable.of(cardList)
            } else {
                return localObservable
                    .subscribeOn(ConcurrentDispatchQueueScheduler.init(queue: backgroundQueue))
            }
        default:
            if let cardList = self.recommendTracks {
                return Observable.concat(Observable.of(cardList), serverObservable)
                    .subscribeOn(ConcurrentDispatchQueueScheduler.init(queue: backgroundQueue))
            } else {
                return Observable.concat(localObservable, serverObservable)
                    .subscribeOn(ConcurrentDispatchQueueScheduler.init(queue: backgroundQueue))
            }
        }
    }

    private func getAllTracksFromServer() -> Observable<[Track]> {
        return api
        .getAllTracks().debug()
            .do(onSuccess: { [weak self] tracks in
                guard let self = self else { return }
                self.allTracks = tracks
            })
            .asObservable()
            .flatMap { [weak self] result -> Observable<([Track], Bool)> in
                guard let self = self else { return Observable.just((result, false)) }
                return Observable.combineLatest(Observable.just(result), self.dataAccess.saveAllTracks(tracks: result)) { ($0, $1) }
            }
            .map { (cards, _) -> [Track] in
                return cards
            }
    }

    func getAllTracks(option: ServiceOption) -> Observable<[Track]> {
        let serverObservable = getAllTracksFromServer()
        let localObservable = dataAccess
            .getLocalAllTracks()
            .compactMap { $0 }
            .doOnNext({ [weak self] cache in
                guard let self = self else { return }
                self.allTracks = cache
            })

        switch option {
        case .server:
            return serverObservable
                .subscribeOn(ConcurrentDispatchQueueScheduler(queue: backgroundQueue))
        case .cache:
            if let cardList = self.allTracks {
                return Observable.of(cardList)
            } else {
                return localObservable
                    .subscribeOn(ConcurrentDispatchQueueScheduler.init(queue: backgroundQueue))
            }
        default:
            if let cardList = self.allTracks {
                return Observable.concat(Observable.of(cardList), serverObservable)
                    .subscribeOn(ConcurrentDispatchQueueScheduler.init(queue: backgroundQueue))
            } else {
                return Observable.concat(localObservable, serverObservable)
                    .subscribeOn(ConcurrentDispatchQueueScheduler.init(queue: backgroundQueue))
            }
        }
    }

    

    private func getAllPlaylistFromServer() -> Observable<[Playlist]> {
        return api
            .playlists()
            .do(onSuccess: { [weak self] tracks in
                guard let self = self else { return }
                self.allPlaylist = tracks
            })
            .asObservable()
            .flatMap { [weak self] result -> Observable<([Playlist], Bool)> in
                guard let self = self else { return Observable.just((result, false)) }
                return Observable.combineLatest(Observable.just(result), self.dataAccess.saveAllPlaylists(playlists: result)) { ($0, $1) }
            }
            .map { (cards, _) -> [Playlist] in
                return cards
            }
    }

    func getAllPlaylist(option: ServiceOption) -> Observable<[Playlist]> {
        let serverObservable = getAllPlaylistFromServer()
        let localObservable = dataAccess
            .getAllPlaylists()
            .compactMap { $0 }
            .doOnNext({ [weak self] cache in
                guard let self = self else { return }
                self.allPlaylist = cache
            })

        switch option {
        case .server:
            return serverObservable
                .subscribeOn(ConcurrentDispatchQueueScheduler(queue: backgroundQueue))
        case .cache:
            if let cardList = self.allPlaylist {
                return Observable.of(cardList)
            } else {
                return localObservable
                    .subscribeOn(ConcurrentDispatchQueueScheduler.init(queue: backgroundQueue))
            }
        default:
            if let cardList = self.allPlaylist {
                return Observable.concat(Observable.of(cardList), serverObservable)
                    .subscribeOn(ConcurrentDispatchQueueScheduler.init(queue: backgroundQueue))
            } else {
                return Observable.concat(localObservable, serverObservable)
                    .subscribeOn(ConcurrentDispatchQueueScheduler.init(queue: backgroundQueue))
            }
        }
    }

    private func getRecommendedPlaylistsFromServer() -> Observable<[Playlist]> {
        return api
            .getRecommendPlaylist()
            .do(onSuccess: { playlists in
                self.recommendPlaylists = playlists
            }, onError: { error in
                debugPrint(error.localizedDescription)
            })
            .asObservable()
            .flatMap { [weak self] result -> Observable<([Playlist], Bool)> in
                guard let self = self else { return Observable.just((result, false)) }
                return Observable.combineLatest(Observable.just(result), self.dataAccess.saveRecommendedPlaylists(playlists: result)) { ($0, $1) }
            }
            .map { (cards, _) -> [Playlist] in
                return cards
            }
    }

    func getRecommendedPlaylists(option: ServiceOption) -> Observable<[Playlist]> {
        let serverObservable = getRecommendedPlaylistsFromServer()
        let localObservable = dataAccess
            .getRecommendedPlaylists()
            .compactMap { $0 }
            .doOnNext({ [weak self] cache in
                guard let self = self else { return }
                self.recommendPlaylists = cache
            })

        switch option {
        case .server:
            return serverObservable
                .subscribeOn(ConcurrentDispatchQueueScheduler(queue: backgroundQueue))
        case .cache:
            if let cardList = self.recommendPlaylists {
                return Observable.of(cardList)
            } else {
                return localObservable
                    .subscribeOn(ConcurrentDispatchQueueScheduler.init(queue: backgroundQueue))
            }
        default:
            if let cardList = self.recommendPlaylists {
                return Observable.concat(Observable.of(cardList), serverObservable)
                    .subscribeOn(ConcurrentDispatchQueueScheduler.init(queue: backgroundQueue))
            } else {
                return Observable.concat(localObservable, serverObservable)
                    .subscribeOn(ConcurrentDispatchQueueScheduler.init(queue: backgroundQueue))
            }
        }
    }

    func mockData() -> Observable<[Track]> {
        var tracks = [Track]()
        return Observable.just(tracks)
    }

    private func getColorsFromServer() -> Observable<[ColorModel]> {
        return api
            .getColorPalettes()
            .do(onSuccess: { playlists in
                self.colors = playlists
            }, onError: { error in
                debugPrint(error.localizedDescription)
            })
            .asObservable()
            .flatMap { [weak self] result -> Observable<([ColorModel], Bool)> in
                guard let self = self else { return Observable.just((result, false)) }
                return Observable.combineLatest(Observable.just(result), self.dataAccess.saveColors(colors: result)) { ($0, $1) }
            }
            .map { (cards, _) -> [ColorModel] in
                return cards
            }
    }


    func getColorPalettes(option: ServiceOption) -> Observable<[ColorModel]> {
        let serverObservable = getColorsFromServer()
        let localObservable = dataAccess
            .getLocalPalettes()
            .compactMap { $0 }
            .doOnNext({ [weak self] cache in
                guard let self = self else { return }
                self.colors = cache
            })

        switch option {
        case .server:
            return serverObservable
                .subscribeOn(ConcurrentDispatchQueueScheduler(queue: backgroundQueue))
        case .cache:
            if let cardList = self.colors {
                return Observable.of(cardList)
            } else {
                return localObservable
                    .subscribeOn(ConcurrentDispatchQueueScheduler.init(queue: backgroundQueue))
            }
        default:
            if let cardList = self.colors {
                return Observable.concat(Observable.of(cardList), serverObservable)
                    .subscribeOn(ConcurrentDispatchQueueScheduler.init(queue: backgroundQueue))
            } else {
                return Observable.concat(localObservable, serverObservable)
                    .subscribeOn(ConcurrentDispatchQueueScheduler.init(queue: backgroundQueue))
            }
        }
    }

    private func getFirmwaresFromServer() -> Observable<[Firmware]> {
        return api
            .getFirmwares()
            .do(onSuccess: { playlists in
                self.firmware = playlists
            }, onError: { error in
                debugPrint(error.localizedDescription)
            })
            .asObservable()
            .flatMap { [weak self] result -> Observable<([Firmware], Bool)> in
                guard let self = self else { return Observable.just((result, false)) }
                return Observable.combineLatest(Observable.just(result), self.dataAccess.saveFirmwares(firmwares: result)) { ($0, $1) }
            }
            .map { (cards, _) -> [Firmware] in
                return cards
            }
    }


    func getFirmwares(option: ServiceOption) -> Observable<[Firmware]> {
        let serverObservable = getFirmwaresFromServer()
        let localObservable = dataAccess
            .getLocalFirmwares()
            .compactMap { $0 }
            .doOnNext({ [weak self] cache in
                guard let self = self else { return }
                self.firmware = cache
            })

        switch option {
        case .server:
            return serverObservable
                .subscribeOn(ConcurrentDispatchQueueScheduler(queue: backgroundQueue))
        case .cache:
            if let cardList = self.firmware {
                return Observable.of(cardList)
            } else {
                return localObservable
                    .subscribeOn(ConcurrentDispatchQueueScheduler.init(queue: backgroundQueue))
            }
        default:
            if let cardList = self.firmware {
                return Observable.concat(Observable.of(cardList), serverObservable)
                    .subscribeOn(ConcurrentDispatchQueueScheduler.init(queue: backgroundQueue))
            } else {
                return Observable.concat(localObservable, serverObservable)
                    .subscribeOn(ConcurrentDispatchQueueScheduler.init(queue: backgroundQueue))
            }
        }
    }

    func queryTracks(word: String) -> Observable<[Track]> {
        return api
            .queryTracks(word: word).asObservable()
    }

    func queryPlaylists(word: String) -> Observable<[Playlist]> {
        return api
            .queryPlaylists(word: word).asObservable()
    }
}
