import AVFoundation
import Combine

/// Errors that can be thrown by a `BufferProcessorStack`.
public enum BufferProcessorStackError: Error {
    
    /// The `BufferProcessorStack` is busy and cannot accept a new buffer.
    case bufferStackIsBusy
    
    /// The `BufferProcessorStack` failed to process the provided sample.
    case failedToProcessSample
}

/// The `BufferProcessorStack` manages 0 or more `BufferProcessor` objects and handles invoking them asynchronously in order.
///
public protocol BufferProcessorStack: AnyObject {
        
    /// Publishes events that happen in the buffer stack
    var layerEventPublisher: AnyPublisher<BufferProcessorStackEvent, Never> { get }
    
    /// Indicates whether the BufferStack is busy processing a prior request.
    ///
    /// If the BufferStack is currently working on a buffer, it will not accept new buffers for processing.
    ///
    var isBusy: Bool { get }
    
    /// Add a processor to the stack.
    ///
    /// - Parameter processor: The `BufferProcessor` to add.
    ///
    func add(_ processor: BufferProcessor)
    
    /// Remove a processor from the stack.
    ///
    /// - Parameter processor: The `BufferProcessor` to remove.
    ///
    func remove(_ processor: BufferProcessor)
        
    /// Process a sample buffer using all contained `BufferProcessor` objects.
    ///
    /// - Parameters:
    ///     - buffer: The buffer to process.
    ///     - orientation: The current video orientation.
    /// - Returns: A publisher which will emit a buffer or a `BufferProcessorStackError` if the sample cannot be processed.
    ///
    /// If there are no `BufferProcessor` objects added to the stack, then the returned buffer will be the same as the input.
    ///
    func process(buffer: CMSampleBuffer, orientation: Orientation) -> AnyPublisher<CMSampleBuffer, BufferProcessorStackError>
}

public enum BufferProcessorStackEvent {
    /// Event that is sent when the layer is being added to the stack heirarchy
    case willAdd(BufferProcessor)
    /// Event that is sent when the layer is added to the stack heirarchy
    case didAdd(BufferProcessor)
    /// Event that is sent when the layer is being removed from stack heirarchy
    case willRemove(BufferProcessor)
    /// Event that is sent when the layer is removed from stack heirarchy
    case didRemove(BufferProcessor)
}
