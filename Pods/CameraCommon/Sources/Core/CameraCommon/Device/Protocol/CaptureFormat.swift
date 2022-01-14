import AVFoundation

/// Describes a video format that can be captured by a `CaptureDevice`.
///
/// This protocol allows us to mock `AVCaptureDevice.Format` objects, which cannot be created manually.
///
public protocol CaptureFormat {
    
    /// The type of media this format captures.
    var type: MediaType { get }
    
    /// The resolution at which this format captures.
    var resolution: VideoResolution { get }
    
    /// Get a description of the format for configuration purposes.
    var captureFormatDescription: FormatDescription { get }
    
    /// The base horizontal viewing angle of the format.
    var fieldOfView: Float { get }
    
    /// The maximum zoom scale allowed by the format.
    var maxZoomFactor: CGFloat { get }
    
    /// The zoom scale at which pixels begin to be upscaled to meet the capture resolution.
    var upscaleZoomFactor: CGFloat { get }
    
    /// A range of the frame rates (in frames per second) that this format supports.
    var frameRateRange: ClosedRange<Float64> { get }
    
    /// Returns whether the format supports the full color range or the limited video color range.
    var isFullColorRange: Bool { get }
    
    /// A set of any special characteristics this format supports.
    var features: Set<MediaSource.Feature> { get }
}

public extension CaptureFormat {
    var avFormat: AVCaptureDevice.Format? { self as? AVCaptureDevice.Format }
}
