import Foundation
import CoreMedia
import CoreGraphics

/// This protocol can be conformed to by objects wishing to receive periodic update events.
///
public protocol Updatable {
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
}
