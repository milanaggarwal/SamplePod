import UIKit
import Combine

/// A top-level definition of an effect's availability to be included within the interface.
///
/// Examples of effect groups are: Stickers, Boards, Filters, Frames, etc.
///
public struct EffectGroup: Identifiable {
    
    /// A publisher which emits `[EffectGroupItem]`.
    public typealias ItemPublisher = AnyPublisher<[EffectGroupItem], EffectGroupError>
    
    /// A publisher which emits `[EffectGroupCategory]`.
    public typealias CategoryPublisher = AnyPublisher<[EffectGroupCategory], EffectGroupError>
    
    /// A publisher which emits `UIImage`.
    public typealias ImagePublisher = AnyPublisher<UIImage, EffectGroupError>
    
    /// Determines the configuration of the picker.
    ///
    /// The `items`, `categories`, and `itemsAndCategories` types rely on the default picker, while the `custom` type allows a completely custom
    /// view controller to be used for the picker interface.
    ///
    public enum PickerConfiguration {
        
        /// The picker shows an ungrouped set of items.
        case items(ItemPublisher)
        
        /// A group effect in which the group itself acts as the item.
        case singleItem(EffectGroupItem)
        
        /// The picker shows items grouped into categories.
        case categories(CategoryPublisher)
        
        /// The picker shows an un-labeled set of items, followed by categorized items.
        case itemsAndCategories(ItemPublisher, CategoryPublisher)
        
        /// A custom picker view controller is used.
        case custom(UIView & EffectPicker)
    }
    
    /// The identifier of the group.
    public let id: UUID
    
    /// The *localized* display name of the effect group.
    public let name: String
    
    /// The icon representing the effect group.
    ///
    /// This is expressed as a combine publisher to allow a remote image to be used as the icon.
    ///
    /// - Note: The icon should be 40x40 points or smaller to avoid being scaled down. All icons will have a 40x40 hit area.
    public let icon: ImagePublisher
    
    /// The ideal size for this group's items to appear at.
    ///
    public let itemSize: CGSize?
    
    /// The picker configuration of the effect group.
    public let pickerConfiguration: PickerConfiguration
    
    /// Stores the selected effect in the effect group. Used when a new effect is selected and the previous effect has to be deselected
    public var selectedItem: EffectGroupItem? {
        _selectedItemPublisher.value
    }
    
    private var _selectedItemPublisher: CurrentValueSubject<EffectGroupItem?, Never> = CurrentValueSubject(nil)
    
    /// Publisher to publish the changes in the selected item in the effect group
    public func selectedItemPublisher() -> AnyPublisher<EffectGroupItem?, Never> {
        _selectedItemPublisher.eraseToAnyPublisher()
    }
    
    /// Sets the selected effect in the effect group
    public func setSelectedItem(item: EffectGroupItem?) {
        _selectedItemPublisher.value = item
    }
        
    /// Create an EffectGroup with an ungrouped item publisher.
    ///
    /// - Parameters:
    ///     - id: The unique identifier for the `EffectGroup`.
    ///     - name: The localized name of the `EffectGroup`.
    ///     - icon: A publisher for the icon representing the `EffectGroup`.
    ///     - items: A publisher for items to show in the default picker.
    ///     - itemSize: An optional size for the items.
    ///
    public init(id: UUID = UUID(),
                name: String,
                icon: ImagePublisher,
                items: ItemPublisher,
                itemSize: CGSize? = nil)
    {
        self.id = id
        self.name = name
        self.icon = icon
        self.pickerConfiguration = .items(items)
        self.itemSize = itemSize
    }
    
    /// Create an EffectGroup with a single item.
    ///
    /// - Parameters:
    ///     - id: The unique identifier for the `EffectGroup`.
    ///     - name: The localized name of the `EffectGroup`.
    ///     - icon: A publisher for the icon representing the `EffectGroup`.
    ///     - effectItem: The effect group item.
    ///
    public init(id: UUID = UUID(),
                name: String,
                icon: ImagePublisher,
                effectItem: EffectGroupItem)
    {
        self.id = id
        self.name = name
        self.icon = icon
        self.pickerConfiguration = .singleItem(effectItem)
        self.itemSize = .zero
    }
    
    /// Create an EffectGroup with a categorized item publisher.
    ///
    /// - Parameters:
    ///     - id: The unique identifier for the `EffectGroup`.
    ///     - name: The localized name of the `EffectGroup`.
    ///     - icon: A publisher for the icon representing the `EffectGroup`.
    ///     - categories: A publisher for categorized items to show in the default picker.
    ///     - itemSize: An optional size for the items.
    ///
    public init(id: UUID = UUID(),
                name: String,
                icon: ImagePublisher,
                categories: CategoryPublisher,
                itemSize: CGSize? = nil)
    {
        self.id = id
        self.name = name
        self.icon = icon
        self.pickerConfiguration = .categories(categories)
        self.itemSize = itemSize
    }
    
    /// Create an EffectGroup with both ungrouped items and a categorized items.
    ///
    /// - Parameters:
    ///     - id: The unique identifier for the `EffectGroup`.
    ///     - name: The localized name of the `EffectGroup`.
    ///     - icon: A publisher for the icon representing the `EffectGroup`.
    ///     - items: A publisher for items to show in the default picker.
    ///     - categories: A publisher for categorized items to show in the default picker.
    ///     - itemSize: An optional size for the items.
    ///
    public init(id: UUID = UUID(),
                name: String,
                icon: ImagePublisher,
                items: ItemPublisher,
                categories: CategoryPublisher,
                itemSize: CGSize? = nil)
    {
        self.id = id
        self.name = name
        self.icon = icon
        self.pickerConfiguration = .itemsAndCategories(items, categories)
        self.itemSize = itemSize
    }
    
    /// Create an EffectGroup with a custom picker.
    ///
    /// - Parameters:
    ///     - id: The unique identifier for the `EffectGroup`.
    ///     - name: The localized name of the `EffectGroup`.
    ///     - pickerView: A custom picker view conforming to the `EffectPicker` protocol.
    ///
    public init(id: UUID = UUID(),
                name: String,
                icon: ImagePublisher,
                pickerView: UIView & EffectPicker)
    {
        self.id = id
        self.name = name
        self.icon = icon
        self.pickerConfiguration = .custom(pickerView)
        self.itemSize = nil
    }
}

// MARK: - Equatable & Hashable

extension EffectGroup: Hashable {
    
    public static func ==(lhs: EffectGroup, rhs: EffectGroup) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
