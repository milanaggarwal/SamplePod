import CoreMedia

/// The `VideoResolution` enum provides quick access to common video resolutions in portrait and landscape orientations.
/// 
public enum VideoResolution: Equatable, Comparable {
    
    /// The source does not capture video.
    case zero
    
    /// 640x480
    case subHD
    
    /// 960x540 (half of 1080p)
    case halfHD
    
    /// 1280x720 (aka 720p)
    case quasiHD
    
    /// 1920x1080 (aka 1080p)
    case fullHD
    
    /// 3840x2160 (aka 4K)
    case ultraHD
    
    /// Any other, non-standard size.
    case other(CMVideoDimensions)
    
    /// Get the size of the video in landscape orientation.
    public var videoDimensions: CMVideoDimensions {
        switch self {
        case .zero:     return CMVideoDimensions(width:    0, height:    0)
        case .subHD:    return CMVideoDimensions(width:  640, height:  480)
        case .halfHD:   return CMVideoDimensions(width:  960, height:  540)
        case .quasiHD:  return CMVideoDimensions(width: 1280, height:  720)
        case .fullHD:   return CMVideoDimensions(width: 1920, height: 1080)
        case .ultraHD:  return CMVideoDimensions(width: 3840, height: 2160)
        case .other(let dimensions): return dimensions
        }
    }
    
    /// The size of the video in landscape orientation.
    public var size: CGSize {
        let dim = self.videoDimensions
        return CGSize(width: CGFloat(dim.width), height: CGFloat(dim.height))
    }
    
    public var portraitSize: CGSize {
        return CGSize(width: size.height, height: size.width)
    }
    
    /// Create an instance of `Resolution` based on the provided dimensions.
    ///
    /// - Parameter dimensions: The `CMVideoDimensions` to consider when selecting the appropriate case.
    /// - Returns: The appropriate `Resolution`.
    ///
    public static func from(dimensions: CMVideoDimensions) -> VideoResolution {
        switch (dimensions.height, dimensions.width) {
        case (   0,    0): return .zero
        case ( 640,  480): return .subHD
        case ( 960,  540): return .halfHD
        case (1280,  720): return .quasiHD
        case (1920, 1080): return .fullHD
        case (3840, 2160): return .ultraHD
        default:
            return other(dimensions)
        }
    }
    
    public static func == (lhs: VideoResolution, rhs: VideoResolution) -> Bool {
        return lhs.videoDimensions == rhs.videoDimensions
    }
    
    public static func < (lhs: VideoResolution, rhs: VideoResolution) -> Bool {
        let lSize = lhs.videoDimensions
        let rSize = rhs.videoDimensions
        return lSize.width * lSize.height < rSize.width * rSize.height
    }
    
    public func size(for orientation: Orientation) -> CGSize {
        if orientation.isLandscape {
            return size
        } else {
            return portraitSize
        }
    }
}
