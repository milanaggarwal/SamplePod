import UIKit
import Combine

/// A selectable member of an `EffectGroup` or `EffectCategory`.
///
/// This type represents a single instance of an effect, such as a pixelate filter or a rainbow frame.
///
public struct EffectGroupItem: Identifiable {
    
    /// A publisher which emits an image or an error.
    public typealias ImagePublisher = AnyPublisher<UIImage, EffectGroupError>
    
    /// The unique identifier of this item.
    public let id: UUID
        
    /// The *localized* display name of the item.
    public let name: String?
    
    /// The icon representing the item.
    ///
    /// This image is requested asynchronously so that groups with many items in them can
    /// load images in batches as needed (like Stickers).
    ///
    public let icon: ImagePublisher?
    
    /// An alternative icon for the item.
    ///
    /// This is to allow for orientation- or device-specific alternate icons to be provided.
    ///
    public let iconAlt: ImagePublisher?
    
    /// A boolean to define whether the item is used to cancel the applied effect
    public let isCancelItem: Bool

    /// The state out of possible states with respect to the effect being applied
    public var state: SearchableCollectionViewItemState {
        stateSubject.value
    }

    /// Holds the current value of the state with default being `noEffect`
    private var stateSubject: CurrentValueSubject<SearchableCollectionViewItemState, Never> = CurrentValueSubject(.noEffect)

    /// This is used to update the value of the state from other places like sourcehandlers of the effect
    public func setState(state: SearchableCollectionViewItemState) -> Void {
        stateSubject.value = state
    }

    /// Publisher to notify the state change in the item
    public func statePublisher() -> AnyPublisher<SearchableCollectionViewItemState, Never> {
        return stateSubject.eraseToAnyPublisher()
    }
    /// Boolean to define if the item is currently selected in the drawer
    public var isSelected: Bool {
        isSelectedSubject.value
    }
    private var isSelectedSubject: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    public func isSelectedPublisher() -> AnyPublisher<Bool, Never> {
        isSelectedSubject.eraseToAnyPublisher()
    }
    /// Sets the `isSelected` property of the item
    public func setIsSelected(isSelected: Bool) -> Void {
        isSelectedSubject.value = isSelected
    }

    /// Create an `EffectGroupItem` with asynchronous images.
    ///
    /// This initializer is designed for the case where an `EffectSource` might want to be able to fetch icons
    /// from a remote URL.
    ///
    /// - Parameters:
    ///     - id: The unique identifier of this Item.
    ///     - name: A localized display name for this Item.
    ///     - icon: A publisher for the icon of this Item.
    ///     - iconAlt: A publisher for the alternate image to display for this Item.
    ///     - isCancelItem: An optional boolean to denote whether the item is used for showing cancel item in the drawer
    ///
    /// - Throws: Will throw `EffectGroupError.allItemPropertiesNil` if the initializer is called with all 3 of
    ///           `name`, `icon`, and `iconAlt` being `nil`.
    ///
    public init(id: UUID = UUID(), name: String?, icon: ImagePublisher?, iconAlt: ImagePublisher?, isCancelItem: Bool = false) throws {
        guard !(name == nil && icon == nil && iconAlt == nil) else {
            throw EffectGroupError.allItemPropertiesNil
        }
        self.id = id
        self.name = name
        self.icon = icon
        self.iconAlt = iconAlt
        self.isCancelItem = isCancelItem
    }
    
    /// Create an `EffectGroupItem` with local images.
    ///
    /// This initializer will take care of creating the necessary publishers in the case where fixed, local
    /// images are being used for the icons.
    ///
    /// - Parameters:
    ///     - id: The unique identifier of this Item.
    ///     - name: A localized display name for this Item.
    ///     - iconImage: An image to display for this Item.
    ///     - iconAltImage: An alternate image to display for this Item.
    ///     - isCancelItem: An optional boolean to denote whether the item is used for showing cancel item in the drawer
    ///
    /// - Throws: Will throw `EffectGroupError.allItemPropertiesNil` if the initializer is called with all 3 of
    ///           `name`, `iconImage`, and `iconAltImage` being `nil`.
    ///
    public init(id: UUID = UUID(), name: String?, iconImage: UIImage?, iconAltImage: UIImage?, isCancelItem: Bool = false) throws {
        guard !(name == nil && iconImage == nil && iconAltImage == nil) else {
            throw EffectGroupError.allItemPropertiesNil
        }
        self.id = id
        self.name = name
        if let iconImage = iconImage {
            self.icon = Just(iconImage)
                .setFailureType(to: EffectGroupError.self)
                .eraseToAnyPublisher()
        } else {
            self.icon = nil
        }
        if let iconAltImage = iconAltImage {
            self.iconAlt = Just(iconAltImage)
                .setFailureType(to: EffectGroupError.self)
                .eraseToAnyPublisher()
        } else {
            self.iconAlt = nil
        }
        self.isCancelItem = isCancelItem
    }
}

// MARK: - Equatable & Hashable

extension EffectGroupItem: Hashable {
    
    public static func ==(lhs: EffectGroupItem, rhs: EffectGroupItem) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
/// Defines the possible states of the item with repect to the currently applied effect
public enum SearchableCollectionViewItemState {
    /// Defines the case when some effect is being applied currently from the group of this item
    case applyingEffect
    /// Defines the case when the effect is active from the group of this item
    case appliedEffect
    /// Defines the case when there is no effect applied in the group of this item
    case noEffect
}
