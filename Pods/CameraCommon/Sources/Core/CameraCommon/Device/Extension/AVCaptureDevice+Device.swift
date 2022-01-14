import AVFoundation

extension AVCaptureDevice: CaptureDevice {
    /// Return the zoom range as a `ClosedRange`.
    public var zoomRange: ClosedRange<CGFloat> { minAvailableVideoZoomFactor...maxAvailableVideoZoomFactor }
    
    public var activeCaptureFormat: CaptureFormat {
        get { activeFormat }
        set {
            guard let newFormat = newValue as? AVCaptureDevice.Format else {
                assertionFailure("Must use an `AVCaptureDevice.Format` object to set the `activeCaptureFormat` value.")
                return
            }
            activeFormat = newFormat
        }
    }
    
    public var captureFormats: [CaptureFormat] { formats }
}

extension AVCaptureDevice.Format: CaptureFormat {
    
    public var type: MediaType {
        switch self.mediaType {
        case .audio: return .audio
        case .video: return .video
        default: return .other
        }
    }
    
    public var resolution: VideoResolution {
        VideoResolution.from(dimensions: formatDescription.dimensions)
    }
    
    public var fieldOfView: Float { self.videoFieldOfView }
    
    public var maxZoomFactor: CGFloat { self.videoMaxZoomFactor }
    
    public var upscaleZoomFactor: CGFloat { self.videoZoomFactorUpscaleThreshold }
    
    public var captureFormatDescription: FormatDescription { self.formatDescription }
    
    public var frameRateRange: ClosedRange<Float64> {
        guard let rawRange = videoSupportedFrameRateRanges.first else {
            return 0...0
        }
        return rawRange.minFrameRate...rawRange.maxFrameRate
    }
    
    public var isFullColorRange: Bool {
        formatDescription.mediaSubType == "420f".fourCharCode
    }
    
    public var features: Set<MediaSource.Feature> {
        var feats = Set<MediaSource.Feature>()
        if !supportedDepthDataFormats.isEmpty { feats.insert(.depth) }
        if frameRateRange.upperBound > 60.0 { feats.insert(.highFrameRate) }
        if isVideoHDRSupported { feats.insert(.hdr) }
        if isVideoBinned { feats.insert(.lowLight) }
        if isVideoStabilizationModeSupported(.auto) { feats.insert(.imageStabilization) }
        if isMultiCamSupported { feats.insert(.multiCam) }
        let still = highResolutionStillImageDimensions
        let res = resolution.videoDimensions
        if still.width > res.width && still.height > res.height {
            feats.insert(.highQualityStill)
        }
        return feats
    }
}

extension AVCaptureDevice.DiscoverySession: DiscoverySession {
    public var captureDevices: [CaptureDevice] { devices }
}

public extension AVCaptureDevice.DeviceType {
    
    /// The sort order is an arbitrary decision about how desirable a particular camera type is.
    ///
    var sortOrder: Int {
        switch self {
        case .builtInWideAngleCamera:
            return 3
        case .builtInDualCamera:
            return 2
        case .builtInTripleCamera:
            return 1
        default:
            return 0
        }
    }
}

public extension AVCaptureDevice.Position {
    
    /// An arbitrary decision about which camera positions we prefer.
    ///
    var sortOrder: Int {
        switch self {
        case .front: return 2
        case .back: return 1
        default: return 0
        }
    }
}
