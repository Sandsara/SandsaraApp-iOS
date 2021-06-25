// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSFont
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIFont
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "FontConvertible.Font", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias Font = FontConvertible.Font

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Fonts

// swiftlint:disable identifier_name line_length type_body_length
internal enum FontFamily {
  internal enum OpenSans {
    internal static let regular = FontConvertible(name: "OpenSans", family: "Open Sans", path: "OpenSans-Regular.ttf")
    internal static let bold = FontConvertible(name: "OpenSans-Bold", family: "Open Sans", path: "OpenSans-Bold.ttf")
    internal static let boldItalic = FontConvertible(name: "OpenSans-BoldItalic", family: "Open Sans", path: "OpenSans-BoldItalic.ttf")
    internal static let extrabold = FontConvertible(name: "OpenSans-Extrabold", family: "Open Sans", path: "OpenSans-ExtraBold.ttf")
    internal static let extraboldItalic = FontConvertible(name: "OpenSans-ExtraboldItalic", family: "Open Sans", path: "OpenSans-ExtraBoldItalic.ttf")
    internal static let italic = FontConvertible(name: "OpenSans-Italic", family: "Open Sans", path: "OpenSans-Italic.ttf")
    internal static let light = FontConvertible(name: "OpenSans-Light", family: "Open Sans", path: "OpenSans-Light.ttf")
    internal static let semibold = FontConvertible(name: "OpenSans-Semibold", family: "Open Sans", path: "OpenSans-Semibold.ttf")
    internal static let semiboldItalic = FontConvertible(name: "OpenSans-SemiboldItalic", family: "Open Sans", path: "OpenSans-SemiboldItalic.ttf")
    internal static let lightItalic = FontConvertible(name: "OpenSansLight-Italic", family: "Open Sans", path: "OpenSans-LightItalic.ttf")
    internal static let all: [FontConvertible] = [regular, bold, boldItalic, extrabold, extraboldItalic, italic, light, semibold, semiboldItalic, lightItalic]
  }
  internal enum Tinos {
    internal static let bold = FontConvertible(name: "Tinos-Bold", family: "Tinos", path: "Tinos-Bold.ttf")
    internal static let boldItalic = FontConvertible(name: "Tinos-BoldItalic", family: "Tinos", path: "Tinos-BoldItalic.ttf")
    internal static let italic = FontConvertible(name: "Tinos-Italic", family: "Tinos", path: "Tinos-Italic.ttf")
    internal static let regular = FontConvertible(name: "Tinos-Regular", family: "Tinos", path: "Tinos-Regular.ttf")
    internal static let all: [FontConvertible] = [bold, boldItalic, italic, regular]
  }
  internal static let allCustomFonts: [FontConvertible] = [OpenSans.all, Tinos.all].flatMap { $0 }
  internal static func registerAllCustomFonts() {
    allCustomFonts.forEach { $0.register() }
  }
}
// swiftlint:enable identifier_name line_length type_body_length

// MARK: - Implementation Details

internal struct FontConvertible {
  internal let name: String
  internal let family: String
  internal let path: String

  #if os(OSX)
  internal typealias Font = NSFont
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Font = UIFont
  #endif

  internal func font(size: CGFloat) -> Font {
    guard let font = Font(font: self, size: size) else {
      fatalError("Unable to initialize font '\(name)' (\(family))")
    }
    return font
  }

  internal func register() {
    // swiftlint:disable:next conditional_returns_on_newline
    guard let url = url else { return }
    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
  }

  fileprivate var url: URL? {
    // swiftlint:disable:next implicit_return
    return BundleToken.bundle.url(forResource: path, withExtension: nil)
  }
}

internal extension FontConvertible.Font {
  convenience init?(font: FontConvertible, size: CGFloat) {
    #if os(iOS) || os(tvOS) || os(watchOS)
    if !UIFont.fontNames(forFamilyName: font.family).contains(font.name) {
      font.register()
    }
    #elseif os(OSX)
    if let url = font.url, CTFontManagerGetScopeForURL(url as CFURL) == .none {
      font.register()
    }
    #endif

    self.init(name: font.name, size: size)
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
