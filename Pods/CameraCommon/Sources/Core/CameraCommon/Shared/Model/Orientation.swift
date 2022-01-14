import AVFoundation
import UIKit

/// A standardized orientation type designed to bridge between the various orientation types
/// used by UIKit and AVFoundation.
///
public enum Orientation: Equatable {
    /// The device is upright with the home button at the bottom or the notch at the top.
    case portrait

    /// The device is upside down with the home button on top or the notch at the bottom.
    case portraitUpsideDown

    /// The device is on its side with the home button on the left or the notch on the right.
    case landscapeRight

    /// The device is on its side with the home button on the right or the notch on the left.
    case landscapeLeft

    /// Get the `UIDeviceOrientation` equivalent of this `Orientation`.
    public var deviceOrientation: UIDeviceOrientation {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeRight: return .landscapeRight
        case .landscapeLeft: return .landscapeLeft
        }
    }

    /// Get the `UIInterfaceOrientation` equivalent of this `Orientation`.
    public var interfaceOrientation: UIInterfaceOrientation {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeRight: return .landscapeLeft
        case .landscapeLeft: return .landscapeRight
        }
    }

    /// Get the `AVCaptureVideoOrientation` equivalent of this `Orientation`.
    public var videoOrientation: AVCaptureVideoOrientation {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeRight: return .landscapeLeft
        case .landscapeLeft: return .landscapeRight
        }
    }

    /// Whether or not the orientation is a `portrait` orientation
    public var isPortrait: Bool {
        switch self {
        case .portrait, .portraitUpsideDown:
            return true
        case .landscapeLeft, .landscapeRight:
            return false
        }
    }

    /// Whether or not the orientation is a `landscape` orientation
    public var isLandscape: Bool {
        !isPortrait
    }

    /// Create an `Orientation` from a `UIDeviceOrientation`.
    ///
    /// - Parameter deviceOrientation: The `UIDeviceOrientation` to convert.
    ///
    /// - Warning: Since the `Orientation` type does not include `.faceUp` and `.faceDown` cases, this is a
    ///            lossy conversion. You will get `.portrait` when you convert back to `UIDeviceOrientation`.
    ///
    public init(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeRight: self = .landscapeRight
        case .landscapeLeft: self = .landscapeLeft
        default: self = .portrait
        }
    }

    /// Create an `Orientation` from a `UIInterfaceOrientation`.
    ///
    /// - Parameter interfaceOrientation: The `UIInterfaceOrientation` to convert.
    ///
    public init(interfaceOrientation: UIInterfaceOrientation) {
        /* We have to invert interfaceOrientation in landscape mode, left to right and vice verse. As by defination interfaceOrientation.lansdcapeRight is mirror of orientation.landscapeLeft, similarly interfaceOrientation.landscapeLeft is mirror of orientation.landscapeRight.
         */
        switch interfaceOrientation {
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeRight: self = .landscapeLeft
        case .landscapeLeft: self = .landscapeRight
        default: self = .portrait
        }
    }

    /// Create an `Orientation` from a `AVCaptureVideoOrientation`.
    ///
    /// - Parameter videoOrientation: The `AVCaptureVideoOrientation` to convert.
    ///
    public init(videoOrientation: AVCaptureVideoOrientation) {
        /* We have to invert videoOrientation in landscape mode, left to right and vice verse. As by defination videoOrientation.lansdcapeRight is mirror of orientation.landscapeLeft, similarly videoOrientation.landscapeLeft is mirror of orientation.landscapeRight.
         */
        switch videoOrientation {
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeRight: self = .landscapeLeft
        case .landscapeLeft: self = .landscapeRight
        default: self = .portrait
        }
    }
    
    /// This method gets the orientation of asset video according to video angle.
    /// -   Parameter :  Angle: It indicates the angle of videTrack
    /// -   Returns: Returns the corresponding Orientation for video angle.
    ///
    static func fromVideoWithAngle(ofDegree degree: CGFloat) -> Orientation? {
        switch Int(degree) {
        case 0: return landscapeRight
        case 90: return portrait
        case 180: return landscapeLeft
        case -90: return portraitUpsideDown
        default: return nil
        }
    }
    
    /// Get the `UIInterfaceOrientation` equivalent of this `Orientation`.
    public var interfaceVideoOrientation: UIInterfaceOrientation {
        switch self {
        case .portrait, .portraitUpsideDown: return .portrait
        case .landscapeRight: return .landscapeRight
        case .landscapeLeft: return .landscapeLeft
        }
    }
}

/// Determine VideoOrientation of an asset
/// It extracts the videoTrack from asset and get it's angle
/// Using videoTrack angle method returns Orientation
public func getAssetOrientation(asset: AVAsset) -> Orientation? {
    guard let firstVideoTrack = asset.tracks.first else {
        return nil
    }
    let transform = firstVideoTrack.preferredTransform
    let videoAngleInDegree = CGFloat.radiansToDegrees(atan2(Double(transform.b), Double(transform.a)))
    return Orientation.fromVideoWithAngle(ofDegree: videoAngleInDegree)
}
