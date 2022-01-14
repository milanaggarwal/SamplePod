import AVFoundation

/// This protocol abstracts the `AVCaptureDevice.DiscoverySession` so that it can be mocked.
///
public protocol DiscoverySession: AnyObject {
    /// Get a list of discovered devices from the DiscoverySession.
    var captureDevices: [CaptureDevice] { get }
}
