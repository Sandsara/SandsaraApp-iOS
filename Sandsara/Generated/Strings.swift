// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// About this Sandsara
  internal static let about = L10n.tr("Localizeable", "about")
  /// Add anyway
  internal static let addAnyway = L10n.tr("Localizeable", "add_anyway")
  /// Add to Playlist
  internal static let addToPlaylist = L10n.tr("Localizeable", "add_to_playlist")
  /// Add to Queue
  internal static let addToQueue = L10n.tr("Localizeable", "add_to_queue")
  /// Advanced Settings
  internal static let advanceSetting = L10n.tr("Localizeable", "advance_setting")
  /// Do you want to delete this playlist ?
  internal static let alertDeletePlaylist = L10n.tr("Localizeable", "alert_delete_playlist")
  /// By %@
  internal static func authorBy(_ p1: Any) -> String {
    return L10n.tr("Localizeable", "author_by", String(describing: p1))
  }
  /// Basic Settings
  internal static let basicSetting = L10n.tr("Localizeable", "basic_setting")
  /// Brightness
  internal static let brightness = L10n.tr("Localizeable", "brightness")
  /// Cancel
  internal static let cancel = L10n.tr("Localizeable", "cancel")
  /// Change Name
  internal static let changeName = L10n.tr("Localizeable", "change_name")
  /// Choose your device
  internal static let chooseDevice = L10n.tr("Localizeable", "choose_device")
  /// Color Pallete
  internal static let colorPallete = L10n.tr("Localizeable", "color_pallete")
  /// Color Temperature
  internal static let colorTemp = L10n.tr("Localizeable", "color_temp")
  /// Make sure your Sandsara is closeby and plugged to the wall.
  internal static let connectDesc = L10n.tr("Localizeable", "connect_desc")
  /// Connect To a Different Sandsara
  internal static let connectNew = L10n.tr("Localizeable", "connect_new")
  /// Connect Now
  internal static let connectNow = L10n.tr("Localizeable", "connect_now")
  /// Connect to Sandsara
  internal static let connectToSandsara = L10n.tr("Localizeable", "connect_to_sandsara")
  /// Connecting
  internal static let connecting = L10n.tr("Localizeable", "connecting")
  /// Create new playlist
  internal static let createPlaylist = L10n.tr("Localizeable", "create_playlist")
  /// Custom Color
  internal static let customColor = L10n.tr("Localizeable", "custom_color")
  /// Cycle
  internal static let cycle = L10n.tr("Localizeable", "cycle")
  /// Name: %@
  internal static func deviceName(_ p1: Any) -> String {
    return L10n.tr("Localizeable", "device_name", String(describing: p1))
  }
  /// Download to Library
  internal static let download = L10n.tr("Localizeable", "download")
  /// Downloaded to Library
  internal static let downloaded = L10n.tr("Localizeable", "downloaded")
  /// Downloading...
  internal static let downloading = L10n.tr("Localizeable", "downloading")
  /// Duplicate track found
  internal static let duplicateFound = L10n.tr("Localizeable", "duplicate_found")
  /// No track here !!!
  internal static let emptyList = L10n.tr("Localizeable", "empty_list")
  /// Factory Reset
  internal static let factoryReset = L10n.tr("Localizeable", "factory_reset")
  /// Favorite
  internal static let favorite = L10n.tr("Localizeable", "favorite")
  /// Favorited
  internal static let favorited = L10n.tr("Localizeable", "favorited")
  /// Firmware Update Available v %@
  internal static func firmwareAlert(_ p1: Any) -> String {
    return L10n.tr("Localizeable", "firmware_alert", String(describing: p1))
  }
  /// Downloading Firmware v %@
  internal static func firmwareDownloading(_ p1: Any) -> String {
    return L10n.tr("Localizeable", "firmware_downloading", String(describing: p1))
  }
  /// Firmware v %@ is Ready
  internal static func firmwareIsReady(_ p1: Any) -> String {
    return L10n.tr("Localizeable", "firmware_is_ready", String(describing: p1))
  }
  /// This process takes about 10 minutes and can’t be cancelled. Please, don’t disconnect your SANDSARA.
  internal static let firmwareNotice = L10n.tr("Localizeable", "firmware_notice")
  /// Syncing Firmware v %@
  internal static func firmwareSyncing(_ p1: Any) -> String {
    return L10n.tr("Localizeable", "firmware_syncing", String(describing: p1))
  }
  /// Update Firmware Now
  internal static let firmwareUpdateNow = L10n.tr("Localizeable", "firmware_update_now")
  /// Current Firmware: %@
  internal static func firmwareVersion(_ p1: Any) -> String {
    return L10n.tr("Localizeable", "firmware_version", String(describing: p1))
  }
  /// Flip Direction
  internal static let flipMode = L10n.tr("Localizeable", "flip_mode")
  /// Help
  internal static let help = L10n.tr("Localizeable", "help")
  /// Light Cycle Speed
  internal static let lightCycleSpeed = L10n.tr("Localizeable", "light_cycle_speed")
  /// Light mode
  internal static let lightmode = L10n.tr("Localizeable", "lightmode")
  /// Queue:
  internal static let nextBy = L10n.tr("Localizeable", "next_by")
  /// No Results
  internal static let noResult = L10n.tr("Localizeable", "no_result")
  /// Ooops, we couldn’t find any Playlists that match your search terms, please try another one.
  internal static let noResultDesc = L10n.tr("Localizeable", "no_result_desc")
  /// No Sandsara detected.
  internal static let noSandsaraDetected = L10n.tr("Localizeable", "no_sandsara_detected")
  /// Now Playing
  internal static let nowPlaying = L10n.tr("Localizeable", "now_playing")
  /// Ok
  internal static let ok = L10n.tr("Localizeable", "ok")
  /// Play
  internal static let play = L10n.tr("Localizeable", "play")
  /// Playlists
  internal static let playlists = L10n.tr("Localizeable", "playlists")
  /// Presets
  internal static let presets = L10n.tr("Localizeable", "presets")
  /// Recommended Playlists
  internal static let recommendedPlaylists = L10n.tr("Localizeable", "recommended_playlists")
  /// Recommended Tracks
  internal static let recommendedTracks = L10n.tr("Localizeable", "recommended_tracks")
  /// Restart
  internal static let restart = L10n.tr("Localizeable", "restart")
  /// Rotate
  internal static let rotate = L10n.tr("Localizeable", "rotate")
  /// Sandsara is calibrating
  internal static let sandsaraCalibrating = L10n.tr("Localizeable", "sandsara_calibrating")
  /// Sandsara detected.
  internal static let sandsaraDetected = L10n.tr("Localizeable", "sandsara_detected")
  /// Sandsara is asleep
  internal static let sandsaraSleep = L10n.tr("Localizeable", "sandsara_sleep")
  /// Settings
  internal static let settings = L10n.tr("Localizeable", "settings")
  /// Sleep
  internal static let sleep = L10n.tr("Localizeable", "sleep")
  /// Ball Speed
  internal static let speed = L10n.tr("Localizeable", "speed")
  /// Static
  internal static let `static` = L10n.tr("Localizeable", "static")
  /// Sync all
  internal static let syncAll = L10n.tr("Localizeable", "sync_all")
  /// Syncing tracks. Playback will resume soon.
  internal static let syncNoti = L10n.tr("Localizeable", "sync_noti")
  /// Sync to Sandsara
  internal static let syncToBoard = L10n.tr("Localizeable", "sync_to_board")
  /// Syncing...
  internal static let syncing = L10n.tr("Localizeable", "syncing")
  /// Tracks
  internal static let tracks = L10n.tr("Localizeable", "tracks")
  /// Update Firmware
  internal static let updateFirmware = L10n.tr("Localizeable", "update_firmware")
  /// Updating...
  internal static let updating = L10n.tr("Localizeable", "updating")
  /// Updating Firmware v %@
  internal static func updatingVersion(_ p1: Any) -> String {
    return L10n.tr("Localizeable", "updating_version", String(describing: p1))
  }
  /// Sandsara’s Website
  internal static let website = L10n.tr("Localizeable", "website")
  /// %@ min estimated
  internal static func xMinEsimated(_ p1: Any) -> String {
    return L10n.tr("Localizeable", "x_min_esimated", String(describing: p1))
  }
  /// %d Tracks need to be synced
  internal static func xTrackNeedToBeSynced(_ p1: Int) -> String {
    return L10n.tr("Localizeable", "x_track_need_to_be_synced", p1)
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
