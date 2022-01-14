import UIKit

/// The default color picker preset available.
/// 
public enum ColorPickerPreset: Int {
    case white
    case red
    case orange
    case yellow
    case green
    case lightBlue
    case blue
    case purple
    case pink
    case black
    case gray

    public var color: UIColor {
        switch self {
        case .white:
            return .white
        case .red:
            return .red
        case .orange:
            return .orange
        case .yellow:
            return .yellow
        case .green:
            return .green
        case .lightBlue:
            return #colorLiteral(red: 0.1137254902, green: 0.631372549, blue: 0.9490196078, alpha: 1)
        case .blue:
            return #colorLiteral(red: 0.2784313725, green: 0.6392156863, blue: 1, alpha: 1)
        case .purple:
            return #colorLiteral(red: 0.737254902, green: 0.4588235294, blue: 1, alpha: 1)
        case .pink:
            return #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        case .black:
            return .black
        case .gray:
            return .gray
        }
    }
    
    /// Returns a UIColor based on a provided value (percentage of view).
    public static func color(at percent: CGFloat) -> UIColor {
        switch percent {
        case 0.00...0.09:
            return ColorPickerPreset.purple.color
        case 0.09...0.18:
            return ColorPickerPreset.pink.color
        case 0.18...0.27:
            return ColorPickerPreset.red.color
        case 0.27...0.36:
            return ColorPickerPreset.orange.color
        case 0.36...0.45:
            return ColorPickerPreset.yellow.color
        case 0.45...0.54:
            return ColorPickerPreset.green.color
        case 0.54...0.63:
            return ColorPickerPreset.lightBlue.color
        case 0.63...0.72:
            return ColorPickerPreset.blue.color
        case 0.72...0.81:
            return ColorPickerPreset.black.color
        case 0.81...0.90:
            return ColorPickerPreset.gray.color
        case 0.91...1.00:
            return ColorPickerPreset.white.color
        default:
            return ColorPickerPreset.white.color
        }
    }
    
    public static func colors() -> [CGColor] {
        var colors: [CGColor] = []
        
        for value in ColorPickerPreset.values {
            colors.append(value.color.cgColor)
        }
        
        return colors
    }

    static let values: [ColorPickerPreset] = [.purple, .pink, .red, .orange, .yellow, .green, .lightBlue, .blue, .black, .gray, .white]
}
