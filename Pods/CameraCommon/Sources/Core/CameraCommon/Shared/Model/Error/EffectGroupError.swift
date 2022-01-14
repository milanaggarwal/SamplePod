import Foundation

/// Errors encountered by the `EffectGroup` or `EffectGroupItem`.
public enum EffectGroupError: Error {
    
    /// The `EffectGroup` was unable to load its child items.
    case unableToLoadItems
    
    /// The Group/Category/Item could not load its image.
    case unableToLoadImage
    
    /// The Source could not create a transform layer for the specified Item.
    case unableToCreateTransformLayer
    
    /// Attempted to create an `EffectGroupItem` where all properties were `nil`.
    case allItemPropertiesNil
}
