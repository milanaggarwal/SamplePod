import UIKit

/// Provides configuration to build icon button
enum ButtonType: Int {
    case rainbow

    var image: UIImage? {
        return CommonAssets.rainbowButton.image
    }
    
    var selectedImage: UIImage? {
        return nil
    }
    
    var height: CGFloat {
        40
    }
    
    var width: CGFloat {
        height
    }
    
    var cornerRadius: CGFloat {
        height / 2
    }
    
    var clipToBounds: Bool {
        false
    }

    var imageEdgeInsets: UIEdgeInsets {
        UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    }
    
    var backgroundColor: UIColor {
        InterfaceCommonColors.offBlack.color
    }

    var selectedBackgroundColor: UIColor {
        switch self {
        case .rainbow:
            return .white
        default:
            return backgroundColor
        }
    }

    var borderColor: UIColor {
        .clear
    }

    var borderWidth: CGFloat {
        0
    }

    var accessibilityLabel: String? {
        #warning("handle accessibilityLabel")
        return nil
    }
}

extension IconButtonConfiguration {
    static func defaultConfiguration(forType type: ButtonType) -> IconButtonConfiguration {
        let configuration = IconButtonConfiguration()
        configuration.image = type.image
        configuration.selectedImage = type.selectedImage
        configuration.height = type.height
        configuration.width = type.width
        configuration.cornerRadius = type.cornerRadius
        configuration.imageEdgeInsets = type.imageEdgeInsets
        configuration.backgroundColor = type.backgroundColor
        configuration.selectedBackgroundColor = type.selectedBackgroundColor
        configuration.clipToBounds = type.clipToBounds
        configuration.borderColor = type.borderColor
        configuration.borderWidth = type.borderWidth
        configuration.accessibilityLabel = type.accessibilityLabel
        return configuration
    }
}
