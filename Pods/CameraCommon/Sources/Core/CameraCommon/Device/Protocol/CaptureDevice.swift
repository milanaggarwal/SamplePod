import AVFoundation

/// Describes a physical capture device, such as a microphone or camera.
///
/// This is a protocol which allows us to substitute mock objects for AVCaptureDevice objects which cannot
/// be manually constructed.
///
public protocol CaptureDevice {
    
    /// Returns the type of device (microphone, single camera, virtual camera, etc.)
    var deviceType: AVCaptureDevice.DeviceType { get }
    
    /// Indicates that the device is virtual, consisting of 2 or more phsical devices.
    var isVirtualDevice: Bool { get }
    
    /// The physical position of the capture device on its parent mobile device.
    var position: AVCaptureDevice.Position { get }
    
    /// Indicates the format that the device is currently configured for.
    ///
    /// Attempting to set this value to a format not obtained by querying this device's `formats` property
    /// will be ignored.
    var activeCaptureFormat: CaptureFormat { get set }
    
    /// An array of available formats for this device.
    var captureFormats: [CaptureFormat] { get }
    
    /// Returns the zoom range achievable by this device.
    var zoomRange: ClosedRange<CGFloat> { get }
}

public extension CaptureDevice {
    var avDevice: AVCaptureDevice? { self as? AVCaptureDevice }
}
