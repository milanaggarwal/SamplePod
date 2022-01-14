import Foundation
import Combine
import UIKit

/// An object conforming to `EffectSource` provides information to the `Interface` library about how to include the
/// effect type in the framework-provided selection interface, as well as providing specific effect instances in the
/// form of `TransformLayer` objects.
///
public class EffectSource: Equatable, Hashable {
    
    /// A closure which accepts an `EffectGroupItem` and returns a publisher that emits either a TransformLayer for
    /// that item or an error.
    ///
    /// - Returns: A publisher which will emit the `TransformLayer` or an error.
    ///
    public typealias ItemResultCallback = (EffectGroupItem) -> AnyPublisher<ItemResult, EffectGroupError>
    
    /// A publisher which emits `UIImage`.
    public typealias ImagePublisher = AnyPublisher<UIImage, EffectGroupError>
    
    /// The result of selecting a particular item from the source.
    ///
    /// The `.noEffect` case allows the source to take an action other than adding a processor or layer. For instance,
    /// it could allow boards to remove an active board.
    ///
    public enum ItemResult {
        /// Tapping the item produced a `BufferProcessor`.
        case bufferProcessor(BufferProcessor)
        
        /// Tapping the item produced a `TransformLayer`.
        case transformLayer(TransformLayer)
        
        /// Tapping the item did not result in an item being added.
        case noEffect
    }
    
    /// The unique identifier for this source.
    public let id: UUID
    
    /// The name of the effects source
    public let name: String
    
    /// The  icon for the effects source.
    public let icon: AnyPublisher<UIImage, EffectGroupError>
        
    /// The `EffectGroup` for this source.
    public let group: EffectGroup
    
    /// Indicates whether or not the group supports string-based searching.
    public let isSearchable: Bool
    
    /// Publisher for the current search term.
    ///
    /// - Note: You may want to debounce the output of this publisher if you are performing a network
    ///         operation with the value.
    ///
    public var searchTerm: AnyPublisher<String?, Never> {
        _searchTerm.eraseToAnyPublisher()
    }
    
    /// The publisher for search terms that an implementor can subscribe to in order to update their group.
    private let _searchTerm = CurrentValueSubject<String?, Never>(nil)
    
    /// Store the transform layer callback.
    private let itemResultCallback: ItemResultCallback
    
    /// Create the EffectSource with a fixed `EffectGroup`.
    ///
    /// This initializer disables searching because there is no way to modify the `EffectGroup` after
    /// the instance is created.
    ///
    /// - Parameters:
    ///     - id: The unique identifier of this Source.
    ///     - groupPublisher: A publisher which will emit `EffectGroup` objects.
    ///     - layerCallback: A closure that accepts a `EffectGroupItem` and returns a publisher that
    ///                      will emit a TransformLayer for that item or an error.
    ///     - isSearchable: Determines whether or not search is supported for this source.
    ///     - searchTerm: An optional starting search term for the Source.
    ///
    public init(id: UUID = UUID(),
                name: String,
                isSearchable: Bool,
                searchTerm: String? = nil,
                iconPublisher: ImagePublisher,
                group: EffectGroup,
                itemResultCallback: @escaping ItemResultCallback)
    {
        self.id = id
        self.name = name
        self.icon = iconPublisher
        self.group = group
        self.isSearchable = isSearchable
        self.itemResultCallback = itemResultCallback
        _searchTerm.value = searchTerm
    }
    
    /// Create the EffectSource with a fixed `EffectGroup`.
    ///
    /// This initializer disables searching because there is no way to modify the `EffectGroup` after
    /// the instance is created.
    ///
    /// - Parameters:
    ///     - id: The unique identifier of this Source.
    ///     - group: The `EffectGroup` that backs this source.
    ///     - layerCallback: A closure that accepts a `EffectGroupItem` and returns a publisher that
    ///                      will emit a TransformLayer for that item or an error.
    ///
    public init(id: UUID = UUID(),
                name: String,
                iconPublisher: ImagePublisher,
                group: EffectGroup,
                itemResultCallback: @escaping ItemResultCallback)
    {
        self.id = id
        self.name = name
        self.icon = iconPublisher
        self.group = group
        self.itemResultCallback = itemResultCallback
        self.isSearchable = false
    }
    
    /// For a given `EffectGroupItem`, return a publisher that will emit an `ItemResult` case.
    ///
    /// - Parameter item: The `EffectGroupItem` to produce a `TransformLayer` for.
    /// - Returns: A publisher which will emit an `ItemResult` case.
    ///
    public func getResult(for item: EffectGroupItem) -> AnyPublisher<ItemResult, EffectGroupError> {
        itemResultCallback(item)
    }
    
    /// Sets the search term.
    ///
    /// This will only do anything if `isSearchable` is `true`.
    ///
    /// - Parameter searchTerm: The new search term
    ///
    public func set(searchTerm: String?) {
        guard isSearchable else { return }
        guard let normalizedTerm = searchTerm?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
            _searchTerm.send(nil)
            return
        }
        _searchTerm.send(normalizedTerm)
    }
    
    // MARK: Equatable
    public static func == (lhs: EffectSource, rhs: EffectSource) -> Bool { lhs.id == rhs.id }
    
    // MARK: Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension EffectSource: Identifiable {}

