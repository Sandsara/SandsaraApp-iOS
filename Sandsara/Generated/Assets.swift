// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let background = ColorAsset(name: "background")
  internal static let primary = ColorAsset(name: "primary")
  internal static let secondary = ColorAsset(name: "secondary")
  internal static let tertiary = ColorAsset(name: "tertiary")
  internal static let image = ImageAsset(name: "Image")
  internal static let _1st = ImageAsset(name: "1st")
  internal static let _2nd = ImageAsset(name: "2nd")
  internal static let _3rd = ImageAsset(name: "3rd")
  internal static let _4th = ImageAsset(name: "4th")
  internal static let add = ImageAsset(name: "add")
  internal static let back = ImageAsset(name: "back")
  internal static let checkmark = ImageAsset(name: "checkmark")
  internal static let close = ImageAsset(name: "close")
  internal static let down = ImageAsset(name: "down")
  internal static let download = ImageAsset(name: "download")
  internal static let favorite = ImageAsset(name: "favorite")
  internal static let icons8Heart60 = ImageAsset(name: "icons8-heart-60")
  internal static let icons8Trash30 = ImageAsset(name: "icons8-trash-30")
  internal static let library = ImageAsset(name: "library")
  internal static let next = ImageAsset(name: "next")
  internal static let notFound = ImageAsset(name: "notFound")
  internal static let pause1 = ImageAsset(name: "pause-1")
  internal static let pause = ImageAsset(name: "pause")
  internal static let placeHolderPlaylist = ImageAsset(name: "placeHolderPlaylist")
  internal static let play = ImageAsset(name: "play")
  internal static let playerPlay = ImageAsset(name: "playerPlay")
  internal static let playlistCover = ImageAsset(name: "playlist Cover")
  internal static let prev = ImageAsset(name: "prev")
  internal static let retry = ImageAsset(name: "retry")
  internal static let search = ImageAsset(name: "search")
  internal static let settings = ImageAsset(name: "settings")
  internal static let smallSearch = ImageAsset(name: "smallSearch")
  internal static let sync1 = ImageAsset(name: "sync-1")
  internal static let sync = ImageAsset(name: "sync")
  internal static let thumbs = ImageAsset(name: "thumbs")
  internal static let toggleBaseOff = ImageAsset(name: "toggle_base_off")
  internal static let toggleBaseOn = ImageAsset(name: "toggle_base_on")
  internal static let trashOutline = ImageAsset(name: "trash-outline")
  internal static let trash = ImageAsset(name: "trash")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
}

internal extension ImageAsset.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
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
