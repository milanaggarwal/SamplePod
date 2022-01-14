import AVFoundation
import Combine

/// A buffer processor acts directly on captured sample buffers before they are wrapped in a CIImage and
/// fed through the `LayerStack`.
///
public protocol BufferProcessor: AnyObject {
    
    /// The unique identifier of the processor.
    var id: UUID { get }
    
    /// A name for the buffer processor used in performance profiling.
    var debugName: StaticString { get }
    
    /// Controls when the processor should be removed.
    ///
    /// The `BufferProcessor` will be removed on the next processing pass after this is set to `true`.
    /// When that occurs, `prepareForRemoval()` will be called instead of `process(...)` after which the
    /// processor will be immediately removed from the stack.
    ///
    var shouldRemoveProcessor: Bool { get set }
        
    /// Ask the `BufferProcessor` to process the buffer.
    ///
    /// This asynchronous operation returns a publisher which will emit a new buffer or the input buffer if no change was made.
    ///
    /// - Parameter buffer: The sample buffer to be processed.
    /// - Parameter orientation: The current capture orientation.
    /// - Returns A publisher which will emit a new buffer or the previous one if no changes were made.
    ///
    func process(buffer: CMSampleBuffer, orientation: Orientation) -> AnyPublisher<CMSampleBuffer, Never>
    
    /// Called by the `BufferProcessorStack` when the buffer processor has been marked for removal.
    func prepareForRemoval()
}
