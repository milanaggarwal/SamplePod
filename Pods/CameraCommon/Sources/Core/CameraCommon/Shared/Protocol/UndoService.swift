import Foundation
import Combine

/// The UndoService manages linked undo/redo stacks to allow
public protocol UndoService: AnyObject {
    
    /// A method to invoke when an action needs to be undone.
    typealias UndoCallback = (UndoAction) -> Void
    
    /// A method to invoke when an action needs to be redone.
    typealias RedoCallback = (UndoAction) -> Void
    
    /// Indicates whether there are any available actions to undo.
    var canUndo: Bool { get }
    
    /// Indicates whether there are any available actions to redo.
    var canRedo: Bool { get }
    
    /// A `Combine` publisher for the availability of undo actions.
    var canUndoPublisher: AnyPublisher<Bool, Never> { get }
    
    /// A `Combine` publisher for the availability of redo actions.
    var canRedoPublisher: AnyPublisher<Bool, Never> { get }    
    
    /// Add an action to the undo stack.
    ///
    /// - Parameters:
    ///     - action: The action that should be managed for undo/redo.
    ///     - undo: The callback to invoke when an action needs to be undone.
    ///     - redo: The callback to invoke when an action needs to be redone.
    ///
    /// - Note: Adding a new item has the side-effect of clearing the redo stack.
    ///
    func add(action: UndoAction, undo: @escaping UndoCallback, redo: @escaping RedoCallback)
    
    /// Invoke an undo of the last action on the stack.
    ///
    /// Takes the last item from the undo stack, invokes its `undo` callback and moves the action
    /// to the redo stack. If the undo stack is empty, then nothing happens.
    ///
    func undo()
    
    /// Invoke an undo of the last undone action on the stack.
    ///
    /// Takes the last item from the redo stack, invokes its `redo` callback and moves the action
    /// to the undo stack. If the redo stack is empty, then nothing happens.
    ///
    func redo()
    
    /// Clear the undo and redo stacks.
    ///
    func clearHistory()
}

