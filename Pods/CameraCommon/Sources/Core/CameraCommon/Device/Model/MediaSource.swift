import AVFoundation

/// Describes a camera available for use in video capture.
///
public struct MediaSource {
    
    /// Indicates special features of this media source.
    public enum Feature: Int, Hashable, Equatable {
        
        /// The source is capable of capturing depth data.
        case depth
        
        /// The source is a high frame-rate "slow-mo" camera.
        case highFrameRate
        
        /// The source virtually bonds 2 or more hardware devices to capture with a wide optical zoom range.
        case virtual
        
        /// The source is capable of high dynamic range recording.
        case hdr
        
        /// The source is more sensitive at low light levels.
        case lowLight
        
        /// The source supports either optical or digital image stabilization.
        case imageStabilization
        
        /// The source supports recording from multiple cameras simultaneously.
        case multiCam
        
        /// The source supports capturing a high quality still image while recording video.
        case highQualityStill
    }
        
    /// A unique identifier for this media source.
    public let id: UUID
    
    /// The media type of the source.
    public var type: MediaType { format?.type ?? .audio }
    
    /// Indicates the position of this media source.
    public var position: AVCaptureDevice.Position { device.position }
    
    /// The resolution at which this device captures video.
    ///
    /// If the device does not capture video, then this value will be `.zero`.
    ///
    public var resolution: VideoResolution { format?.resolution ?? .zero }
    
    /// The zoom range suppoted by this source.
    public var zoomRange: ClosedRange<CGFloat> { device.zoomRange }
    
    /// The features of this media source.
    public var features: Set<Feature> {
        guard let format = self.format else { return Set() }
        var features = format.features
        if device.isVirtualDevice {
            features.insert(.virtual)
        }
        return features
    }
    
    public let device: CaptureDevice
    
    public let format: CaptureFormat?
    
    public init(id: UUID = UUID(), device: CaptureDevice, format: CaptureFormat?) {
        self.id = id
        self.device = device
        self.format = format
    }
}

extension MediaSource: Equatable {
    public static func == (lhs: MediaSource, rhs: MediaSource) -> Bool {
        return lhs.id == rhs.id
    }
}

extension MediaSource: Comparable {
    
    // Sorts the media sources first by the desirability of their backing hardware and then by resolution.
    // Most desirable is first.
    
    public static func < (lhs: MediaSource, rhs: MediaSource) -> Bool {
        let lSort = lhs.device.deviceType.sortOrder
        let rSort = rhs.device.deviceType.sortOrder
        guard lSort == rSort else { return lSort > rSort }
        return lhs.resolution > rhs.resolution
    }
}
