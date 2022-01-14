import Combine
import AVFoundation

/// A `SampleSource` emits sample buffers and provides basic controls for starting and stopping action.
///
/// This protocol allows us to abstract whether the source of the samples is live capture from device's
/// hardware, a video file, or some other source of video data.
///
public protocol SampleSource: AnyObject {
    
    /// A closure that handles samples emerging from a SampleSource.
    typealias SampleHandler = (CMSampleBuffer) -> Void
    
    /// A closure that handles errors emerging from a SampleSource.
    typealias ErrorHandler = (SampleSourceError) -> Void
    
    /// A unique identifier used for equality checks (removing sources).
    ///
    var id: UUID { get }
    
    /// Indicates whether or not the source is currently active and producing frames.
    ///
    var isActive: Bool { get }

    /// Indicates that the source should begin emitting samples.
    ///
    /// The source will not emit any samples until this method is called.
    ///
    func start()
    
    /// Indicates that the source should stop emitting samples.
    ///
    /// The source will not emit any samples after stop is called.
    ///
    func stop()
    
    /// A Combine interface for receiving samples from the sample source.
    ///
    /// - Warning: This publisher makes no gaurantees about which thread will be used
    ///            to send the samples; do not assume samples will arrive on the main thread.
    ///
    var samples: AnyPublisher<CMSampleBuffer, SampleSourceError> { get }
}
