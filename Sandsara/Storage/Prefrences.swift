//
//  Prefrences.swift
//  MiniYoutubePlayer
//
//  Created by tin on 5/4/20.
//  Copyright © 2020 tin. All rights reserved.
//
import Foundation

@propertyWrapper
/// User default initial
final class UserDefault<T> where T: Codable {
    private(set) var key: String
    let defaultValue: T?

    private var userDefault: UserDefaults
    
    
    init(_ key: String,
         defaultValue: T?,
         userDefault: UserDefaults = UserDefaults.standard,
         domain: String = "com.ios.sandsara") {
        self.key = key
        self.defaultValue = defaultValue
        self.userDefault = userDefault
    }
    var wrappedValue: T? {
        get {
            let value = userDefault.object(forKey: key)
            if value is Data { //-- Array, enum, class, struct type
                let obj = T.toObject(type: T.self, from: value as! Data)
                return obj ?? defaultValue
            } else { //-- primitive type: Int, String, Double, Bool
                return (value as? T) ?? defaultValue
            }
        }
        set {
            if (newValue is String) || (newValue is Int) || (newValue is Double) || (newValue is Bool) || (newValue is Data) {
                userDefault.set(newValue, forKey: key)
            } else {
                let newData = newValue?.toData()
                userDefault.set(newData, forKey: key)
            }
            userDefault.synchronize()
        }
    }

    var projectedValue: UserDefault<T> { return self }

    func setKey(_ key: String) {
        self.key = key
    }
}

struct Preferences {

    static var prefixDomain: String {
        return "user_defaults.mobytelab_"
    }
    
    /// App Domain
    struct AppDomain {
        @UserDefault(Keys.currentAppLanguage.key, defaultValue: nil)
        /// app lang
        static var currentAppLanguage: String?
        
        @UserDefault(Keys.firmwareVersion.key, defaultValue: nil)
        /// Current firmware version
        static var firmwareVersion: String?

        @UserDefault(Keys.colors.key, defaultValue: nil)
        /// colors array stored
        static var colors: [ColorModel]?

        @UserDefault(Keys.firmware.key, defaultValue: nil)
        /// avaiable firmware stored
        static var firmware: [Firmware]?
        
        @UserDefault(Keys.connectedBoard.key, defaultValue: nil)
        /// Connected device identifier
        static var connectedBoard: ConnectedPeripheralIdentifier?

        enum Keys: String {
            case currentAppLanguage
            case connectedSandasa
            case colors
            case firmwareVersion
            case firmware
            case connectedBoard

            var key: String {
                return Preferences.prefixDomain + self.rawValue
            }
        }
    }
    
    /// Playlist Domain
    struct PlaylistsDomain {
        @UserDefault(Keys.recommendedTracks.key, defaultValue: nil)
        static var recommendTracks: [Track]?

        @UserDefault(Keys.allTracks.key, defaultValue: nil)
        static var allTracks: [Track]?

        @UserDefault(Keys.recommendedPlaylists.key, defaultValue: nil)
        static var recommendedPlaylists: [Playlist]?

        @UserDefault(Keys.allRemotePlaylists.key, defaultValue: nil)
        static var allRemotePlaylists: [Playlist]?

        @UserDefault(Keys.playlistDetail.key, defaultValue: nil)
        static var playlistDetail: [Track]?
        

        enum Keys: String {
            case recommendedTracks
            case recommendedPlaylists
            case allTracks
            case allRemotePlaylists
            case playlistDetail

            var key: String {
                return Preferences.prefixDomain + self.rawValue
            }
        }
    }
}


public struct ConnectedPeripheralIdentifier: Codable {
    /// The UUID of the peripheral.
    public let uuid: UUID
    
    /// The name of the peripheral.
    public let name: String
    
    /// Returns both the name and uuid of the peripheral.
    public var description: String {
        return "Peripheral: \(name), UUID: \(uuid)"
    }
    
    /// Create a PeripheralIdentifier using a UUID.
    public init(uuid: UUID, name: String?) {
        self.uuid = uuid
        self.name = name ?? "No Name"
    }
}
