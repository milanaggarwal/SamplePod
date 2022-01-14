import UIKit

/// Helps in coverting UIKit frame coordinates to CIImage coordinate and vice-verse
/// 
public struct CoordinateConverter {
    private let videoSize: CGSize
    private var videoBounds: CGRect {
        CGRect(origin: .zero, size: videoSize)
    }
    private let videoFrame: CGRect
    private let screenScale: CGFloat
    public init(videoSize: CGSize, videoFrame: CGRect, screenScale: CGFloat) {
        self.videoSize = videoSize
        self.videoFrame = videoFrame
        self.screenScale = screenScale
    }
    /// Converts the `.extent` property of a `CIImage` to a CGRect in the coordinate space of the video frame.
    public func convert(extent: CGRect) -> CGRect {
        /// The scaling factor from the video size to the frame size.
        
        let videoScaleFactor = min(videoFrame.width * screenScale / videoSize.width, videoFrame.height * screenScale / videoSize.height)
        let inverseScale = 1.0 / screenScale
        let scaledVideoSize = videoSize
            .applying(CGAffineTransform(scaleX: inverseScale, y: inverseScale))
            .applying(CGAffineTransform(scaleX: videoScaleFactor, y: videoScaleFactor))
        let rectWidth = extent.width / screenScale
        let rectHeight = extent.height / screenScale
        let rectOrigin = CoordinateConverter.convert(ciPoint: extent.origin, in: videoBounds, screenScale: screenScale)
        // This is the extent converted to the UIKit coordinate system within the bounds
        // of the video size (not the screen size of the video).
        let rect = CGRect(origin: rectOrigin, size: CGSize(width: rectWidth, height: rectHeight))
        // Scale the video coordinate rect to a screen coordinate rect.
        let scaledRect = rect.applying(CGAffineTransform(scaleX: videoScaleFactor, y: videoScaleFactor))
        let overflowX = (scaledVideoSize.width - videoFrame.width) / 2.0
        let overflowY = (scaledVideoSize.height - videoFrame.height) / 2.0
        // Offset the screen coordinate rect by the frame offset of the video on screen.
        let adjustedRect = scaledRect.offsetBy(dx: videoFrame.origin.x - overflowX, dy: videoFrame.origin.y - overflowY)
        // Flip across Y axis to get rect as per UIKit coordinate
        return CGRect(x: adjustedRect.origin.x, y: adjustedRect.origin.y - adjustedRect.height, width: adjustedRect.width, height: adjustedRect.height)
    }
    
    ///Convert frame to extent
    public func convert(frame: CGRect) -> CGRect {
        /// The scaling factor from the video size to the frame size.
        let videoScaleFactor = min(videoFrame.width * screenScale / videoSize.width, videoFrame.height * screenScale / videoSize.height)
        let inverseScale = 1.0 / screenScale
        let scaledVideoSize = videoSize
            .applying(CGAffineTransform(scaleX: inverseScale, y: inverseScale))
            .applying(CGAffineTransform(scaleX: videoScaleFactor, y: videoScaleFactor))
        let extentWidth = frame.width * screenScale
        let extentHeight = frame.height * screenScale
        let extentOrigin = CoordinateConverter.convert(cgPoint: frame.origin, in: videoBounds, screenScale: screenScale)
        // This is the frame converted to the CI coordinate system.
        let extent = CGRect(origin: extentOrigin, size: CGSize(width: extentWidth, height: extentHeight))
        // Scale the video coordinate rect to the video size.
        let scaledExtent = extent.applying(CGAffineTransform(scaleX: 1/videoScaleFactor, y: 1/videoScaleFactor))
        let overflowX = (scaledVideoSize.width - videoFrame.width) / 2.0
        let overflowY = (scaledVideoSize.height - videoFrame.height) / 2.0
        // Offset the screen coordinate rect by the frame offset of the video on screen.
        let adjustedExtent = scaledExtent.offsetBy(dx: videoFrame.origin.x + overflowX, dy: videoFrame.origin.y + overflowY)
        // Flip across Y axis to get rect as per CI coordinate
        return CGRect(x: adjustedExtent.origin.x, y: adjustedExtent.origin.y + adjustedExtent.height, width: adjustedExtent.width, height: adjustedExtent.height)
    }

    public static func convert(ciPoint: CGPoint, in rect: CGRect, screenScale scale: CGFloat) -> CGPoint {
        let x = ciPoint.x / scale
        let y = (rect.maxY - ciPoint.y) / scale
        return CGPoint(x: x, y: y)
    }
    
    public static func convert(cgPoint: CGPoint, in rect: CGRect, screenScale scale: CGFloat) -> CGPoint {
        let x = cgPoint.x * scale
        let y = (rect.maxY - cgPoint.y) * scale
        return CGPoint(x: x, y: y)
    }
}
