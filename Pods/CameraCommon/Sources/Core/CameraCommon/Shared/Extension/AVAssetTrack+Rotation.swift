import Foundation
import AVFoundation

extension AVAssetTrack {
    
    /// This method is designed to calculate a rotational transform to be applied when videoTrack is rotated 90 degree left
    ///
    /// - Parameter mirrored:  Flag indicates if videoTrack is mirrored
    /// - Returns: Returns transformation needs to be applied when video is rotated
    ///
    public func transformForLeft90DegreeRotation(mirrored: Bool) -> CGAffineTransform {
        let translate = CGAffineTransform(translationX: -naturalSize.width, y: 0)
        let degrees = CGFloat.degreesToRadians(-90)
        let rotate = CGAffineTransform(rotationAngle: degrees)
        var transform = translate
        if mirrored {
            transform = verticalMirrorTransform().concatenating(translate)
        }
        transform = transform.concatenating(rotate)
        return transform
    }
    
    /// This method is designed to calculate a rotational transform to be applied when videoTrack is rotated 90 degree right
    ///
    /// - Parameter mirrored:  Flag indicates if videoTrack is mirrored
    /// - Returns: Returns transformation needs to be applied when video is rotated
    ///
    public func transformForRight90DegreeRotation(mirrored: Bool) -> CGAffineTransform {
        let translate = CGAffineTransform(translationX: 0, y: -naturalSize.height)
        let degrees = CGFloat.degreesToRadians(90)
        let rotate = CGAffineTransform(rotationAngle: degrees)
        var transform = translate
        if mirrored {
            transform = verticalMirrorTransform().concatenating(translate)
        }
        transform = transform.concatenating(rotate)
        return transform
    }
    
    /// This method is designed to calculate a rotational transform to be applied when videoTrack is rotated 180 degree
    ///
    /// - Parameter mirrored:  Flag indicates if videoTrack is mirrored
    /// - Returns: Returns transformation needs to be applied when video is rotated
    ///
    public func transformFor180DegreeRotation(mirrored: Bool) -> CGAffineTransform {
        let translate = CGAffineTransform(translationX: -naturalSize.width, y: -naturalSize.height)
        let degrees = CGFloat.degreesToRadians(180)
        let rotate = CGAffineTransform(rotationAngle: degrees)
        var transform = translate
        if mirrored {
            transform = horizontalMirrorTransform().concatenating(translate)
        }
        transform = transform.concatenating(rotate)
        return transform
    }

    /// Default transform according to mirrored flag
    public func preferredTransform(mirrored: Bool) -> CGAffineTransform {
        if mirrored {
            return horizontalMirrorTransform()
        } else {
            return preferredTransform
        }
    }

    private func horizontalMirrorTransform() -> CGAffineTransform {
        CGAffineTransform(scaleX: -1.0, y: 1.0).translatedBy(x: -naturalSize.width, y: 0)
    }

    private func verticalMirrorTransform() -> CGAffineTransform {
        CGAffineTransform(scaleX: 1.0, y: -1.0).translatedBy(x: 0, y: -naturalSize.height)
    }
}

extension CGFloat {
    static func radiansToDegrees(_ radians: CGFloat) -> CGFloat {
        CGFloat(radians * 180.0 / CGFloat.pi)
    }

    static func degreesToRadians(_ degrees: CGFloat) -> CGFloat {
        CGFloat(degrees * CGFloat.pi / 180.0)
    }
}

extension CGSize {
    public var aspectRatio: CGFloat {
        width / height
    }

    var invertedAspectRatio: CGFloat {
        height / width
    }
}

