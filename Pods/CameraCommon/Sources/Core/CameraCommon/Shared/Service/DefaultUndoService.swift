import Foundation
import Combine

public class DefaultUndoService: UndoService {
    
    /// Stores an undo action in the stack.
    private struct UndoEntry {
        /// The action to undo/redo.
        let action: UndoAction
        
        /// The method to invoke when an undo is needed.
        let undo: UndoCallback
        
        /// The method to invoke when a redo is needed.
        let redo: RedoCallback
    }
    
    public static var shared: DefaultUndoService = DefaultUndoService()
    
    /// The undo stack.
    private var undoStack: [UndoEntry] = []
    
    /// The redo stack.
    private var redoStack: [UndoEntry] = []
    
    /// The publisher for the availability of undo.
    lazy private var _undoPublisher = CurrentValueSubject<Bool, Never>(false)
    
    /// The publisher for the availability of redo.
    lazy private var _redoPublisher = CurrentValueSubject<Bool, Never>(false)
    
    /// Create an instance of the `DefaultUndoService`.
    public init() {}
    
    // MARK: - Protocol Conformance
    
    public var canUndo: Bool { return !undoStack.isEmpty }
    public var canRedo: Bool { return !redoStack.isEmpty }
    
    public var canUndoPublisher: AnyPublisher<Bool, Never> { _undoPublisher.eraseToAnyPublisher() }
    
    public var canRedoPublisher: AnyPublisher<Bool, Never> { _redoPublisher.eraseToAnyPublisher() }
    
    public func add(action: UndoAction, undo: @escaping UndoCallback, redo: @escaping RedoCallback) {
        undoStack.append(UndoEntry(action: action, undo: undo, redo: redo))
        redoStack = []
        
        // Inform subscribers of state change.
        _undoPublisher.send(true)
        _redoPublisher.send(false)
    }
    
    public func undo() {
        guard !undoStack.isEmpty else { return }
        let undoItem = undoStack.removeLast()
        redoStack.append(undoItem)
        undoItem.undo(undoItem.action)
        
        // Inform subscribers of state change.
        _redoPublisher.send(true)
        if !canUndo { _undoPublisher.send(false) }
    }
    
    public func redo() {
        guard !redoStack.isEmpty else { return }
        let redoItem = redoStack.removeLast()
        undoStack.append(redoItem)
        redoItem.redo(redoItem.action)
        
        // Inform subscribers of state change.
        _undoPublisher.send(true)
        if !canRedo { _redoPublisher.send(false) }
    }
    
    public func clearHistory() {
        undoStack = []
        redoStack = []
        
        // Inform subscribers of state change.
        _undoPublisher.send(false)
        _redoPublisher.send(false)
    }
}
