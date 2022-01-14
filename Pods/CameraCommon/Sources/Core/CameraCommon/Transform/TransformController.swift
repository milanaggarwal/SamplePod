import UIKit
import AVFoundation
import Combine

/// The `TransformController` is the heart of the CameraTransform library. It coordinates the transformation
/// of various inputs into the final output image or video frame.
///
public protocol TransformController: AnyObject {
    
    /// The manager for features passed to layers during the update phase.
    var featureManager: FeatureManager { get }
    
    /// The buffer processor stack.
    var processorStack: BufferProcessorStack { get }
    
    /// The layer management stack.
    var layerStack: TransformLayerStack { get }
    
    /// Provides a view which will display the final output of the rendering pipeline if
    /// the `destination` property is set to `.screen` or `.screenAndBuffer`.
    var renderView: UIView { get }
    
    /// Transforms the input frame and returns it.
    ///
    /// If the `destination` includes buffer output, it will be returned via delegate and the buffer publisher.
    ///
    /// - Parameters:
    ///     - frame: The audio or video sample to transform.
    ///     - orientation: The current video orientation.
    ///
    func transform(buffer: CMSampleBuffer, orientation: Orientation) -> AnyPublisher<CMSampleBuffer, TransformControllerError>
}
