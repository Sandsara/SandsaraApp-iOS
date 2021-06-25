//
//  Endpoint.swift
//  Sandsara
//
//  Created by Tín Phan on 14/11/2020.
//

import Foundation
import Moya
// here you write your apikey
let token = "key"
enum SandsaraAPI {
    case recommendedplaylist
    case recommendedtracks
    case playlists
    case playlistDetail
    case alltrack
    case colorPalette
    case firmware
    case searchTrack(word: String)
    case searchPlaylist(word: String)
}

extension String {

    static func ==(lhs: String, rhs: String) -> Bool {
        return lhs.compare(rhs, options: .numeric) == .orderedSame
    }

    static func <(lhs: String, rhs: String) -> Bool {
        return lhs.compare(rhs, options: .numeric) == .orderedAscending
    }

    static func <=(lhs: String, rhs: String) -> Bool {
        return lhs.compare(rhs, options: .numeric) == .orderedAscending || lhs.compare(rhs, options: .numeric) == .orderedSame
    }

    static func >(lhs: String, rhs: String) -> Bool {
        return lhs.compare(rhs, options: .numeric) == .orderedDescending
    }

    static func >=(lhs: String, rhs: String) -> Bool {
        return lhs.compare(rhs, options: .numeric) == .orderedDescending || lhs.compare(rhs, options: .numeric) == .orderedSame
    }

}

extension SandsaraAPI: TargetType {


    var method: Moya.Method {
        return .get
    }

    /// here you have to use the endpoint for the date base
    var baseURL: URL {
        return URL(string: "endpoint of the data base")!
    }

    var path: String {
        switch self {
        case .recommendedtracks:
            return "tracks"
        case .alltrack:
            return "tracks"
        case .recommendedplaylist:
            return "playlist"
        case .playlists:
            return "playlist"
        case .colorPalette:
            return "colorPalette"
        case .firmware:
            return "firmware"
        case .playlistDetail:
            return "playlists"
        case .searchTrack:
            return "tracks"
        case .searchPlaylist:
            return "playlist"
        }
    }



    var headers: [String : String]? {
        return ["Authorization": "Bearer \(token)"]
    }

    var task: Task {
        switch self {
        case .recommendedplaylist, .recommendedtracks:
            return .requestParameters(parameters: ["view": "recommended"], encoding: URLEncoding.default)
        case .alltrack, .playlists:
            return .requestParameters(parameters: ["view": "all",
                                                   "sort[0][field]" : "name"], encoding: URLEncoding.default)
        case let .searchTrack(word):
            let params = buildSearchParameter(word: word)
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case let .searchPlaylist(word):
            let params = buildSearchParameter(word: word)
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        default:
            return .requestPlain
        }
    }

    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }

    private func buildSearchParameter(word: String) -> [String: Any] {
        let words = word.components(separatedBy: " ").map {
          "FIND(\"\($0)\", LOWER({name}&{author})) > 0"
        }

        let encodedWord = words.joined(separator: ",")
        return [
            "view": "all",
            "sort[0][field]" : "name",
            "filterByFormula" : "AND(\(encodedWord))"
        ]
    }
}

import Alamofire
struct CustomUrlEncoding : ParameterEncoding {
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()

        guard let parameters = parameters else { return urlRequest }

        guard let url = urlRequest.url else {
            throw AFError.parameterEncodingFailed(reason: .missingURL)
        }

        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
            let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters: parameters)
            urlComponents.percentEncodedQuery = percentEncodedQuery
            urlRequest.url = urlComponents.url
        }

        return urlRequest
    }

    private func query(parameters: Parameters) -> String {
        var components: [(String, String)] = []

        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }

    public func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []

        if let array = value as? [Any] {
            components.append((key, encode(array: array, separatedBy: ",")))
        } else {
            components.append((key, "\(value)"))
        }

        return components
    }

    private func encode(array: [Any], separatedBy separator: String) -> String {
        return array.map({"\($0)"}).joined(separator: separator)
    }
}
