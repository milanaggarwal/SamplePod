// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum InterfaceStrings {
  public enum Board {
    /// Board
    public static let board = InterfaceStrings.tr("Localizable", "board.board")
    /// Boards
    public static let boards = InterfaceStrings.tr("Localizable", "board.boards")
    /// Apply a board effect.
    public static let effectTypeDescription = InterfaceStrings.tr("Localizable", "board.effect_type_description")
  }

    public enum Common {
        /// Back
        public static let back = InterfaceStrings.tr("Localizable", "common.back")
        /// Cancel
        public static let cancel = InterfaceStrings.tr("Localizable", "common.cancel")
        /// Close
        public static let close = InterfaceStrings.tr("Localizable", "common.close")
    }

  public enum Drawer {
    /// Close Drawer
    public static let close = InterfaceStrings.tr("Localizable", "drawer.close")
  }

  public enum Filter {
    /// Apply a filter effect.
    public static let effectTypeDescription = InterfaceStrings.tr("Localizable", "filter.effect_type_description")
    /// Filter
    public static let filter = InterfaceStrings.tr("Localizable", "filter.filter")
    /// Filters
    public static let filters = InterfaceStrings.tr("Localizable", "filter.filters")
  }

  public enum Frame {
    /// Apply a frame effect.
    public static let effectTypeDescription = InterfaceStrings.tr("Localizable", "frame.effect_type_description")
    /// Frame
    public static let frame = InterfaceStrings.tr("Localizable", "frame.frame")
    /// Frames
    public static let frames = InterfaceStrings.tr("Localizable", "frame.frames")
  }

  public enum Lenses {
    /// Backdrops
    public static let backdrops = InterfaceStrings.tr("Localizable", "lenses.backdrops")
    /// Apply a lens effect.
    public static let effectTypeDescription = InterfaceStrings.tr("Localizable", "lenses.effect_type_description")
    /// Lenses
    public static let lenses = InterfaceStrings.tr("Localizable", "lenses.lenses")
  }

  public enum Pen {
    /// Apply a pen effect.
    public static let effectTypeDescription = InterfaceStrings.tr("Localizable", "pen.effect_type_description")
    /// Pen
    public static let pen = InterfaceStrings.tr("Localizable", "pen.pen")
  }

  public enum Photo {
    /// Apply a photo effect.
    public static let effectTypeDescription = InterfaceStrings.tr("Localizable", "photo.effect_type_description")
    /// Photo
    public static let photo = InterfaceStrings.tr("Localizable", "photo.photo")
  }

  public enum Record {
    public enum BottomBar {
      /// Effects
      public static let effects = InterfaceStrings.tr("Localizable", "record.bottom_bar.effects")
      /// Next
      public static let next = InterfaceStrings.tr("Localizable", "record.bottom_bar.next")
      /// Options
      public static let options = InterfaceStrings.tr("Localizable", "record.bottom_bar.options")
      /// Record
      public static let record = InterfaceStrings.tr("Localizable", "record.bottom_bar.record")
      /// Retake
      public static let retake = InterfaceStrings.tr("Localizable", "record.bottom_bar.retake")
    }
  }

  public enum Sticker {
    /// Apply a sticker effect.
    public static let effectTypeDescription = InterfaceStrings.tr("Localizable", "sticker.effect_type_description")
    /// Sticker
    public static let sticker = InterfaceStrings.tr("Localizable", "sticker.sticker")
    /// Stickers
    public static let stickers = InterfaceStrings.tr("Localizable", "sticker.stickers")
  }

  public enum Text {
    /// Apply a text effect.
    public static let effectTypeDescription = InterfaceStrings.tr("Localizable", "text.effect_type_description")
    /// Text
    public static let text = InterfaceStrings.tr("Localizable", "text.text")
  }

    public enum close {
        public enum app {
            /// Close app warning
            public static let warning = InterfaceStrings.tr("Localizable", "close.app.warning")
        }
    }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension InterfaceStrings {
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
