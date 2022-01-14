import AVFoundation
import Combine

/// A `SampleOutput` takes a final sample buffer and performs some finishing action on it.
///
/// Some example output types:
///
/// - Write to storage as a video file
/// - Render to screen
/// - Send to a remote device or API
///
/// Specific implementations of SampleOutput can allow for multiple writing sessions or be one-use.
///
public protocol SampleOutput {
    
    /// The callback which is invoked as a result of an output.
    typealias Completion = (Result<Void, SampleOutputError>) -> Void
    
    /// A unique identifier used to check for equality between outputs .
    var id: UUID { get }
    
    /// Indicates whether or not the `SampleOutput` is active and accepting samples.
    ///
    var isActive: Bool { get }
    
    /// Perform a finishing action on the supplied sample.
    ///
    /// - Parameter sample: The sample to output.
    /// - Returns: A publisher that will either complete or return an error.
    ///
    func output(sample: CMSampleBuffer) -> AnyPublisher<Void, SampleOutputError>
}
