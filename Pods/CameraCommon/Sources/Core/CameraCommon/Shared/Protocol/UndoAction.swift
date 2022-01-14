import Foundation

/// A protocol used by the Undo/Redo system.
///
/// Objects can implement whatever payload they need to undo/redo an action. Objects will only receive back
/// actions that they emit.
///
public protocol UndoAction {
    /// The unique identifier for the action.
    var id: UUID { get }
}
