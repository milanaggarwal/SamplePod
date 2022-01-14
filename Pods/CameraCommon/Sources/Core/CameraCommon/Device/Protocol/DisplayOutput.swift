import Foundation
import CoreMedia

/// A `DisplayOutput` accepts samples for display on screen.
///
/// Unlike a `SampleOutput`, the one method on `DisplayOutput` is synchronous so it can be used inline.
///
public protocol DisplayOutput: AnyObject {
    
    /// Accepts a sample for display.
    ///
    /// Any internal issues which may prevent the display of the sample should be handled internally, as the method
    /// is not allowed to produce an error.
    ///
    /// - Parameter sample: The sample to display.
    ///
    func output(sample: CMSampleBuffer)
}
