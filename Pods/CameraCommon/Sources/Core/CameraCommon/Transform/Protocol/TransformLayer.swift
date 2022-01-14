import UIKit
import AVFoundation
import Combine

/// An object which contributes to the transformation of an image or video frame.
///
/// Collectively, objects implementing this protocol are referred to as "layers".
///
public protocol TransformLayer: AnyObject, Updatable {
    
// MARK: Properties
    
    /// Layer identifier.
    var id: UUID { get }
    
    /// Whether the layer should be remain the lowest layer at the bottom of the stack
    var shouldRemainAtBottom: Bool { get }
    
    /// Determines the depth ordering of the layer. Higher values will be in front of lower values.
    ///
    /// - Note: No value will ever be placed behind the input image/video.
    var zIndex: Int { get set }
    
    /// Determines whether or not the layer contributes to the transformation pipeline.
    ///
    /// When a layer is hidden, it will not be receive update, render or tap detection calls.
    var isHidden: Bool { get set }
    
    /// Indicates that a layer should be removed from the stack.
    ///
    /// This should always start with a value of `false`. When set to `true`, the stack will remove the
    /// layer after calling `prepareForRemoval()` on the next update cycle.
    ///
    /// - Note: The layer will *not* receive a call to `update(...)` on the pass where it is removed.
    ///
    var shouldRemoveLayer: Bool { get set }
    
    /// The string used when performance profiling this layer.
    var debugName: StaticString { get }
    
// MARK: - Initialization & Lifecycle
    
    /// Create an instance of the layer with the provided size and orientation.
    ///
    /// - Parameter size: The size of the final image output (in pixels).
    /// - Parameter orientation: The current video orientation.
    init(withSize size: CGSize, orientation: Orientation)
    
    /// This method is called just before the layer is removed from the stack.
    ///
    /// The layer will be removed on the next Update phase and will not be retained the stack any further.
    /// This is a good opportunity to free any resources being held by the layer or cancel any long-running tasks.
    ///
    /// - Note: This method is called *instead* of `update(...)` on the pass where it is removed.
    ///
    func prepareForRemoval()
    
// MARK: - Configuration
    
    /// Returns a view capable of configuring the layer's options.
    ///
    /// The view should have a transparent background and be designed to be layered over a dark background.
    ///
    /// - Returns: A view that can configure the layer's options or `nil` if the layer is not configurable.
    ///
    func getConfigurationInterface() -> UIView?
    
// MARK: - Update and Render
    
    /// This method is invoked during the update phase and allows the layer to adjust its its internal state
    /// so that it can quickly respond to the render cycle.
    ///
    /// This method call should be the starting point for any long-running or complex calculations, which should
    /// take place off the main thread. Remember that the results of these calculations should only be applied
    /// to the layer's properties accessed by the `render(withInput:)` on the main thread to avoid the having a
    /// property being read and written to simultaneously.
    ///
    /// - Parameters:
    ///     - size: The size of the final render frame, in pixels.
    ///     - orientation: The current camera orientation.
    ///     - time: The current recording time.
    ///     - features: A dictionary of values which may be useful to the layer in computing its state.
    ///                 The keys for standard values are found in the `TransformLayerFeaturesKey` type.
    ///
    func update(withSize size: CGSize, orientation: Orientation, time: CMTime, features: [String : Any])
    
    /// Takes the image which is the accumulation of lower levels and returns a CIImage which contains the
    /// layer's transformation.
    ///
    /// This function should not perform any complex computations, it is expected that the call will return as
    /// quickly as possible. If complex or asynchronous calculations are required, they should be performed in
    /// response to the `update(withSize:orientation:time:features:)` call.
    ///
    /// - Parameter image: The input CIImage to be transformed.
    /// - Returns: A `CIImage` that is the result of applying the layer's transformation to the input image. If the
    ///            layer returns `nil` for this call, it will be skipped for the current rendering pass.
    ///
    func render(withInput image: CIImage) -> CIImage?

// MARK: - Gesture Recognition
    
    /// Allows a layer to become selected in response to a user's tap.
    ///
    /// - Parameter point: The point which the user tapped on.
    /// - Parameter inRect: The rect in which the point is located.
    /// - Returns: A `Bool` indicating whether or not this layer should become selected.
    ///
    /// - Note: The point and rect will be in UIKit's coordinate system. This can be converted using
    ///         `CGPoint.ciPoint(inRect:scale:)` extension.
    ///
    func shouldBecomeSelected(fromTap point: CGPoint, inRect rect: CGRect) -> Bool
}

// MARK: - Default Implementations

public extension TransformLayer {
    
    // Most layers will not stick to the bottom of the stack
    var shouldRemainAtBottom : Bool {
        return false
    }
    
    // Most layer types do not need gesture support.
    //
    func shouldBecomeSelected(fromTap point: CGPoint, inRect rect: CGRect) -> Bool { false }
}
