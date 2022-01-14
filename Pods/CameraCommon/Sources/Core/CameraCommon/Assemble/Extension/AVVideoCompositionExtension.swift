import AVFoundation
import UIKit

extension AVVideoComposition {
    
    /// Return videoComposition of incoming Asset on the basis of it's orientation
    public static func videoComposition(for asset: AVAsset, forcePortrait: Bool, orientation: UIInterfaceOrientation, preset: AVCaptureSession.Preset? = nil, mirror: Bool) -> AVVideoComposition? {
        guard let videoTrack = asset.tracks(withMediaType: .video).first else { return nil }
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = preset?.renderSize ?? videoTrack.naturalSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        
        let compositionInstruction = getVideoCompositionInstruction(videoComposition: videoComposition, duration: asset.duration, videoTrack: videoTrack, forcePortrait: forcePortrait, mirror: mirror, orientation: orientation)
        
        videoComposition.instructions = [compositionInstruction]
        return videoComposition
    }
    
    /// Returns the transformed AVVideoCompositionInstruction
    private static func getVideoCompositionInstruction(videoComposition: AVMutableVideoComposition,duration: CMTime, videoTrack: AVAssetTrack, forcePortrait: Bool, mirror: Bool, orientation: UIInterfaceOrientation) -> AVVideoCompositionInstruction {
        
        let compositionInstruction = AVMutableVideoCompositionInstruction()
        compositionInstruction.timeRange = CMTimeRange(start: .zero, duration: duration)
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        let transform = getVideoCompositionTransformation(videoComposition: videoComposition, videoTrack: videoTrack, forcePortrait: forcePortrait, mirror: mirror, orientation: orientation)
        layerInstruction.setTransform(transform, at: .zero)
        compositionInstruction.layerInstructions = [layerInstruction]
        return compositionInstruction
    }
    
    private static func getVideoCompositionTransformation(videoComposition: AVMutableVideoComposition, videoTrack: AVAssetTrack, forcePortrait: Bool, mirror: Bool, orientation: UIInterfaceOrientation) -> CGAffineTransform {
        var transform: CGAffineTransform = .identity
        
        if forcePortrait {
            videoComposition.renderSize = CGSize(width: videoComposition.renderSize.height, height: videoComposition.renderSize.width)
            transform = transformForPortraitOrientation(videoComposition: videoComposition,videoTrack: videoTrack, orientation: orientation, mirror: mirror)
        } else {
            switch orientation {
            case .landscapeRight:
                if videoTrack.naturalSize.height > videoTrack.naturalSize.width {
                    videoComposition.renderSize = CGSize(width: videoComposition.renderSize.height, height: videoComposition.renderSize.width)
                }
                transform = videoTrack.transformForLeft90DegreeRotation(mirrored: mirror)
            case .landscapeLeft:
                if videoTrack.naturalSize.height > videoTrack.naturalSize.width {
                    videoComposition.renderSize = CGSize(width: videoComposition.renderSize.height, height: videoComposition.renderSize.width)
                }
                transform = videoTrack.transformForRight90DegreeRotation(mirrored: mirror)
            case .portraitUpsideDown:
                transform = videoTrack.transformFor180DegreeRotation(mirrored: mirror)
            default:
                transform = videoTrack.preferredTransform(mirrored: mirror)
            }
        }
        return transform
    }
    
    
    /// Get videoTranform need to perform on the bais of orientation
    private static func transformForPortraitOrientation(videoComposition: AVMutableVideoComposition,videoTrack: AVAssetTrack, orientation: UIInterfaceOrientation, mirror: Bool) -> CGAffineTransform {
        
        var  result = getTransformAndSizeForPortraitOrientation(videoTrack: videoTrack, orientation: orientation, mirror: mirror)
        var transform = result.transform
        let originalSize = result.size
        // Scale this down on import if needed to create all clips to be the same size
        let incomingRectScaled = AVMakeRect(aspectRatio: originalSize, insideRect: CGRect(origin: .zero, size: videoComposition.renderSize))
        let xScale = incomingRectScaled.width / originalSize.width
        let yScale = incomingRectScaled.height / originalSize.height
        let scaleTransform = CGAffineTransform(scaleX: xScale, y: yScale)
        if videoComposition.renderSize.aspectRatio != originalSize.aspectRatio {
            let translateTransform = scaleTransform.concatenating(CGAffineTransform(translationX: incomingRectScaled.origin.x, y: incomingRectScaled.origin.y))
            transform = transform.concatenating(translateTransform)
        } else if originalSize.width != videoComposition.renderSize.width &&
                    originalSize.height != videoComposition.renderSize.height
        {
            // Scales up or down depending on size. This is if the video is the same aspect ratio.
            transform = transform.concatenating(scaleTransform)
        }
        return transform
    }
    
    private static func getTransformAndSizeForPortraitOrientation(videoTrack: AVAssetTrack, orientation: UIInterfaceOrientation, mirror: Bool) -> (transform:CGAffineTransform, size: CGSize)  {
        var transform: CGAffineTransform = .identity
        var originalSize = videoTrack.naturalSize
        if videoTrack.naturalSize.height > videoTrack.naturalSize.width {
            switch orientation {
            case .landscapeLeft:
                // The video is already laid out correctly here as a portrait video that has a landscape preferred transform. Only on opposite landscape we should rotate 180 degrees.
                // Sample video that repeats this: Screen recording in landscape on iPad is recorded vertically.
                break
            case .landscapeRight:
                transform = videoTrack.transformFor180DegreeRotation(mirrored: mirror)
            default:
                transform = videoTrack.preferredTransform(mirrored: mirror)
            }
        } else {
            switch orientation {
            case .landscapeLeft:
                transform = videoTrack.transformForRight90DegreeRotation(mirrored: mirror)
            case .landscapeRight:
                transform = videoTrack.transformForRight90DegreeRotation(mirrored: mirror)
            case .portrait, .portraitUpsideDown:
                // Sample video that repeats this: Timelapse video shot in portrait.
                transform = videoTrack.transformForRight90DegreeRotation(mirrored: mirror)
            default: break
            }
            originalSize = CGSize(width: originalSize.height, height: originalSize.width)
        }
        
        return (transform, originalSize)
    }
}

extension AVCaptureSession.Preset {
    public var renderSize: CGSize {
        switch self {
        case .cif352x288:
            return CGSize(width: 352, height: 288)
        case .vga640x480:
            return CGSize(width: 640, height: 480)
        case .iFrame960x540:
            return CGSize(width: 960, height: 540)
        case .hd1280x720, .iFrame1280x720:
            return CGSize(width: 1280, height: 720)
        case .hd1920x1080, .high, .medium, .low, .photo:
            return CGSize(width: 1920, height: 1080)
        case .hd4K3840x2160:
            return CGSize(width: 3840, height: 2160)
        default:
            return CGSize(width: 1920, height: 1080)
        }
    }
}
