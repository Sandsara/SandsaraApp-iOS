//
//  APIService.swift
//  Sandsara
//
//  Created by Tín Phan on 14/11/2020.
//

import RxSwift
import Moya
import Alamofire

enum ServiceOption {
    case cache
    case server
    case both //-- geting data from cache first and then getting from API
}

protocol APIServiceCall {
    func getRecommendPlaylist() -> Single<[Playlist]>
    func getRecommendTracks() -> Single<[Track]>
    func playlists() -> Single<[Playlist]>
    func playlistDetail() -> Single<[Track]>
    func getAllTracks() -> Single<[Track]>
    func queryTracks(word: String) -> Single<[Track]>
    func queryPlaylists(word: String) -> Single<[Playlist]>
}

class SandsaraAPIService: APIServiceCall {

    let apiProvider: MoyaProvider<SandsaraAPI>

    init(apiProvider: MoyaProvider<SandsaraAPI>) {
        self.apiProvider = apiProvider
    }

    func getRecommendTracks() -> Single<[Track]> {
        return apiProvider
            .rx.request(.recommendedtracks)
            .debug()
            .map(TracksResponse.self).map {
                $0.tracks.map {
                    $0.playlist
                }
            }
    }

    func getRecommendPlaylist() -> Single<[Playlist]> {
        return apiProvider
            .rx.request(.recommendedplaylist)
            .debug()
            .map(PlaylistsResponse.self)
            .map {
                $0.playlists.map {
                    $0.playlist
                }
            }
    }

    func playlistDetail() -> Single<[Track]> {
        return apiProvider
            .rx.request(.playlistDetail)
            .debug()
            .map(TracksResponse.self)
            .map {
                $0.tracks.map {
                    $0.playlist
                }
            }
    }

    func playlists() -> Single<[Playlist]> {
        return apiProvider
            .rx.request(.playlists)
            .map(PlaylistsResponse.self)
            .map {
                $0.playlists.map {
                    $0.playlist
                }
            }
    }

    func getAllTracks() -> Single<[Track]> {
        return apiProvider
            .rx.request(.alltrack)
            .map(TracksResponse.self)
            .map {
                $0.tracks.map {
                    $0.playlist
                }
            }
    }

    func getColorPalettes() -> Single<[ColorModel]> {
        return apiProvider
            .rx.request(.colorPalette)
            .map(ColorsResponse.self)
            .map {
                $0.colors.map {
                    $0.color
                }
            }
    }

    func getFirmwares() -> Single<[Firmware]> {
        return apiProvider
            .rx.request(.firmware)
            .map(FirmwaresResponse.self)
            .map {
                $0.firmwares.map {
                    $0.firmware
                }
            }
    }

    func queryTracks(word: String) -> Single<[Track]> {
        return apiProvider
            .rx.request(.searchTrack(word: word.lowercased()))
            .map(TracksResponse.self)
            .map {
                $0.tracks.map {
                    $0.playlist
                }
            }
    }

    func queryPlaylists(word: String) -> Single<[Playlist]> {
        return apiProvider
            .rx.request(.searchPlaylist(word: word.lowercased()))
            .map(PlaylistsResponse.self)
            .map {
                $0.playlists.map {
                    $0.playlist
                }
            }
    }
}
