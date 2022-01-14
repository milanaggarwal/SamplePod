import UIKit
import CameraCommon
import InterfaceCommon

/// Allows routing of the proper effect type.
public enum EffectType {
    case board
    case filter
    case frame
    case pen
    case sticker
    case text
    case photo
    
    public var name: StaticString {
        switch self {
        case .board: return "Board"
        case .filter: return "Filter"
        case .frame: return "Frame"
        case .pen: return "Pen"
        case .sticker: return "Sticker"
        case .text: return "Text"
        case .photo: return "Photo"
        }
    }
    
    public var description: String {
        switch self {
        case .board: return InterfaceStrings.Board.effectTypeDescription
        case .filter: return InterfaceStrings.Filter.effectTypeDescription
        case .frame: return InterfaceStrings.Frame.effectTypeDescription
        case .pen: return InterfaceStrings.Pen.effectTypeDescription
        case .sticker: return InterfaceStrings.Sticker.effectTypeDescription
        case .text: return InterfaceStrings.Text.effectTypeDescription
        case .photo: return InterfaceStrings.Photo.effectTypeDescription
        }
    }
}

open class Effect {
    /// The name of the specified effect.
    public let name: String
    
    /// The type of the effect. e.g. boards, frames, etc.
    public let type: EffectType
    
    /// The thumbnail image for the effect
    public let image: Data
    
    public init(name: String, type: EffectType, image: Data) {
        self.name = name
        self.type = type
        self.image = image
    }
}
