import Foundation

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
public typealias AssetColorTypeAlias = ColorAsset.Color

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum InterfaceCommonColors {
    public static let primaryRed = ColorAsset(name: "Colors/primaryRed")
    public static let flipBlue = ColorAsset(name: "Colors/flipBlue")
    public static let blackWithAlpha = ColorAsset(name: "Colors/blackWithAlpha")
    public static let lightBlackWithAlpha = ColorAsset(name: "Colors/lightBlackWithAlpha")
    public static let offBlack = ColorAsset(name: "Colors/offBlack")
    public static let drawerBlack = ColorAsset(name: "Colors/drawerBlack")
    public static let borderShadow = ColorAsset(name: "Colors/borderShadow")
    public static let drawerBackground = ColorAsset(name: "Colors/drawerBackground")
    
    internal static let placeholderGray = ColorAsset(name: "Colors/placeholderGray")
    internal static let primaryYellow = ColorAsset(name: "Colors/primaryYellow")
    internal static let primaryGreen = ColorAsset(name: "Colors/primaryGreen")
}

// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public struct ColorAsset {
    internal fileprivate(set) var name: String
    
    #if os(macOS)
    public typealias Color = NSColor
    #elseif os(iOS) || os(tvOS) || os(watchOS)
    public typealias Color = UIColor
    #endif
    
    public var color: UIColor {
        let bundle = BundleToken.bundle
        #if os(iOS) || os(tvOS)
        let color = UIColor(named: name, in: bundle, compatibleWith: nil)
        #elseif os(macOS)
        let name = NSImage.Name(self.name)
        let color = (bundle == .main) ? NSColor(named: name) : bundle.color(forResource: name)
        #elseif os(watchOS)
        let color = UIColor(named: name)
        #endif
        guard let result = color else {
            fatalError("Unable to load color asset named \(name).")
        }
        return result
    }
}

public extension ColorAsset.Color {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ColorAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name))
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
      if let path = Bundle(for: BundleToken.self).path(forResource: "InterfaceCommonResources", ofType: "bundle"),
         let bundlePackage = Bundle(path: path) {
          return bundlePackage
      } else {
          return Bundle(for: BundleToken.self)
      }
    #endif
  }()
}
// swiftlint:enable convenience_type

