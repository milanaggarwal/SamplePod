import UIKit

/// This protocol allows us to substitute mocks for UIDevice.
public protocol Device {
    /// Get the full model name from the system.
    ///
    /// Useful for determining which processor generation the device has.
    ///
    var modelName: String { get }
    
    /// Determines whether effect rendering is practical on the device.
    ///
    /// Checks to see if the current device is one of the lower-end devices which cannot handle
    /// the complexity of the effect rendering pipeline.
    ///
    func isEffectCapable(modelName: String?) -> Bool
}

/// Declare conformance which is implemented in the `UIDevice+Transform` file.
extension UIDevice: Device {}
