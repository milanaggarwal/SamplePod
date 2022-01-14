import Foundation
import Combine

/// An object conforming to `EffectService` manages the various effects to be made available to the user.
///
public protocol EffectService: AnyObject {
    
    /// The callback for selection success/failure.
    typealias SelectionCallback = (Result<Void, EffectServiceError>) -> Void
    
    // MARK: EffectSource CRUD operations
    
    /// Adds an effect source to the end of the list. If the source already exists within the list, it is updated in-place.
    ///
    /// - Parameter sources: An array of 1 or more `EffectSource` objects to add.
    ///
    func addOrUpdate(sources: [EffectSource])
    
    /// Adds an `EffectSource` at the specified index.
    ///
    /// If the provided `EffectSource` is already present in the list, it is removed and the new one is inserted at the specified index.
    ///
    /// - Parameter source: The `EffectSource` to add.
    /// - Parameter atIndex: The index to add the source at. If the specified index is invalid (out of range),
    ///                      then the closest valid index will be substituted.
    ///
    func insert(source: EffectSource, atIndex: Int)
    
    /// Remove the `EffectSource` from the list.
    ///
    /// - Parameter source: The `EffectSource` to remove.
    /// - Throws: A `EffectServiceError` if the source could not be removed (usually because it was not found).
    ///
    /// - Note: This will *not* remove any currently-applied `BufferProcessor` or `TransformLayer` objects that came from this source.
    ///
    func remove(source: EffectSource) throws
    
    /// Remove the `EffectSource` from the list.
    ///
    /// - Parameter byId: The ID of the `EffectSource` to remove.
    /// - Throws: A `EffectServiceError` if the source could not be removed (usually because it was not found).
    ///
    func remove(byId: UUID) throws
    
    /// Remove all `EffectSource` objects.
    ///
    func removeAll()
    
    // MARK: - Select EffectSource
    
    /// A publisher which emits an updated array of `EffectSource` objects when the list changes in any way.
    var effectSources: AnyPublisher<[EffectSource], Never> { get }
    
    /// A snapshot of the current list of `EffectSource` objects.
    var currentEffectSources: [EffectSource] { get }
    
    /// Used by the UI to tell the `EffectService` that a particular item from a group was selected.
    ///
    /// This is used by the `EffectSource` and its backing data source to create the appropriate `BufferProcessor`, `TransformLayer`,
    /// or to remove an existing processor or layer.
    ///
    /// - Parameters:
    ///     - item: The selected `EffectGroupItem`.
    ///     - source: The `EffectSource` that created the item.
    ///     - completion: The success/failure callback that will be invoked on completion.
    ///
    func select(item: EffectGroupItem, from source: EffectSource, completion: @escaping SelectionCallback)
}
