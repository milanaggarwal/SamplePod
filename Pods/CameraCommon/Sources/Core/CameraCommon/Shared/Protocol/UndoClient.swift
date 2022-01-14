import Foundation
import Combine

/// An object conforming to `UndoClient` can generate undo events and has methods to handle
/// the undo-ing and redo-ing of those events.
///
public protocol UndoClient {
    
    /// The publisher of undo actions for this object.
    ///
    var actions: AnyPublisher<UndoAction, Never> { get }
    
    /// Instructs the object to undo the previously-emitted undo action.
    ///
    /// The `undo(action:)` method will only be invoked with undo actions in the reverse of the order they were emitted in.
    /// The `UndoService` will never call them out-of-order, so there is no need to account for discontinuous undoing of actions.
    ///
    /// For example, if the publisher emits actions A, B, and C, then starts undo-ing, the order that `undo(action:)` will be invoked
    /// in will be: C -> B -> A.
    ///
    /// - Parameter action: The action to be undone.
    ///
    ///
    func undo(action: UndoAction)
    
    /// Instructs the object to redo the previously-undone action.
    ///
    /// The `redo(action:)` method will only be invoked in the reverse order of undone actions.
    ///
    /// For example, if actions A, B, and C are emitted and the user undoes C and undoes B, then `redo` will be invoked in the order: B -> C.
    ///
    /// - Parameter action: The action to redo.
    ///
    func redo(action: UndoAction)
}
