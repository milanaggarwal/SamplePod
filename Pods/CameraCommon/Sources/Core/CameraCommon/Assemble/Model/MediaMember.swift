import Foundation
import Combine
import AVFoundation

/// A `MediaMember` is a member representation of a `MediaAsset`.
///
/// By default, all `MediaMembers` adopt a bounded start and end time identical to the asset they represent. This behavior
/// can be changed to loop the member by adjusting
///
public final class MediaMember: Member {
                
    /// Indicates the rotation of a clip from the original media orientation.
    ///
    public enum Rotation: Int, Codable {
        
        /// No rotation. The clip is in its original orientation.
        case none = 0
        
        /// The clip is rotated 90° clockwise.
        case clockwise90 = 90
        
        /// The clip is rotated 180° clockwise.
        case clockwise180 = 180
        
        /// The clip is rotated 270° clockwise.
        case clockwise270 = 270
        
        /// Return the rotation angle in degrees.
        public var degrees: Double { Double(self.rawValue) }
        
        /// Return the rotation angle in radians.
        public var radians: Double { degrees / 180.0 * Double.pi }
        
        /// Return the next clockwise rotation angle.
        public var nextClockwise: Rotation {
            switch self {
            case .none:         return .clockwise90
            case .clockwise90:  return .clockwise180
            case .clockwise180: return .clockwise270
            case .clockwise270: return .none
            }
        }
        
        /// Return the next counter-clockwise rotation angle.
        public var nextCounterClockwise: Rotation {
            switch self {
            case .none:         return .clockwise270
            case .clockwise90:  return .none
            case .clockwise180: return .clockwise90
            case .clockwise270: return .clockwise180
            }
        }
    }
    
    /// The untrimmed duration of the clip's media asset.
    ///
    public var totalDuration: CMTime { mediaAsset.duration }
    
    /// The untrimmed time range of the clip's media asset.
    public var totalTimeRange: CMTimeRange { CMTimeRange(start: .zero, end: totalDuration) }
    
    /// Indicates whether or not the clip should be flipped horizontally.
    ///
    /// For clips based on audio-only media files, this property has no effect.
    ///
    /// - Note: This transformation is always applied *before* rotation.
    ///
    private(set) public var isMirrored: Bool
    
    /// Indicates the clip's rotational offset from the original media orientation.
    ///
    /// For clips based on audio-only media files, this property has no effect.
    ///
    /// - Note: This transformation is always applied *after* mirroring.
    ///
    private(set) public var rotation: Rotation
    
    /// The member's type must match that of its parent track.
    ///
    public let mediaType: MediaTrack.MediaType
    
    /// The media backing this `MediaMember`.
    ///
    public let mediaAsset: MediaAsset
    
    /// Control whether or not the member's media loops when the member is longer than its media clip.
    public var loopMedia: Bool = true
        
    /// Initialize a new `MediaMember` for an audio clip.
    ///
    /// - Parameters:
    ///     - id: The unique identifier of this `MediaMember`.
    ///     - audioClip: The source media.
    ///     - repeats: Indicates whether the audio member will loop.
    ///
    public init(id: UUID = UUID(), audioAsset: MediaAsset, repeats: Bool = false) {
        self.mediaType = .audio
        self.mediaAsset = audioAsset
        self.isMirrored = false
        self.rotation = .none
        let start: CMTime? = repeats ? nil : .zero
        let end: CMTime? = repeats ? nil : audioAsset.duration
        super.init(id: id, type: .media, startTime: start, endTime: end)
    }
    
    /// Initialize a new `MediaMember` for a video clip.
    ///
    /// The Member will be created with a start time of `.zero` and an end time equal to the clip's `duration`.
    ///
    /// - Parameters:
    ///     - id: The unique identifier of this `MediaMember`.
    ///     - videoClip: The source media.
    ///
    public init(id: UUID = UUID(), media: MediaAsset, isMirrored: Bool = false, rotation: Rotation = .none) {
        self.mediaType = .video
        self.mediaAsset = media
        self.isMirrored = isMirrored
        self.rotation = rotation
        let start: CMTime = .zero
        let end: CMTime = media.duration
        super.init(id: id, type: .media, startTime: start, endTime: end)
    }
    
    /// Adds the member's media to the provided track, looping if necessary.
    ///
    /// If this member's backing media clip does not contain the media type of the track, then
    /// nothing will be added to the track.
    ///
    /// - Parameters:
    ///     - track: The composition track that this member will add it's media to.
    ///     - maxTime: A value which represents the maximum time of the overall composition. Used to trim excess time from the media.
    ///
    /// - Throws: Bubbles up errors related to adding the media to the track.
    ///
    public func add(to track: AVMutableCompositionTrack, atTime: CMTime, maxTime: CMTime) throws {
        guard try contains(mediaType: track.mediaType) else {
            return
        }
        if loopMedia {
            let loops = Int(ceil(duration.seconds / mediaAsset.duration.seconds))
            let start = startTime ?? .zero
            for i in 0..<loops {
                let offsetSeconds = mediaAsset.duration.seconds * Double(i)
                let offset = CMTime(seconds: offsetSeconds, preferredTimescale: mediaAsset.duration.timescale)
                try self.addMedia(to: track, atTime: atTime, maxTime: maxTime)
            }
        } else {
            try self.addMedia(to: track, atTime: atTime ?? .zero, maxTime: maxTime)
        }
    }
    
    /// Set the start time of the clip, allowing the start of the media to be trimmed.
    ///
    /// - Parameter startTime: The new start time of the clip. This value must fall between `.zero` and the `endTime`.
    /// - Throws: `MediaClipError.invalidTime` if the start time is invalid.
    ///
    public func set(startTime: CMTime) throws {
        guard let endTime = endTime, startTime >= .zero && startTime <= endTime else { throw MediaMemberError.invalidTime }
        self.startTime = startTime
    }
    
    /// Mirror the video member on the Y-Axis
    public func mirror() {
        guard mediaType == .video else { return }
        isMirrored = !isMirrored
    }
    
    /// Rotate the video member clockwise by 90
    public func clockWiseRotate() {
        guard mediaType == .video else { return }
        rotation = rotation.nextClockwise
    }
    
    /// Rotate the video member counter clockwise by 90
    public func counterClockWiseRotate() {
        guard mediaType == .video else { return }
        rotation = rotation.nextCounterClockwise
    }
    
    /// Sent the end time of the clip, allowing the end of the media to be trimmed.
    ///
    /// - Parameter endTime: The new end time of the clip. This value must fall between the `startTime`
    ///                      and the duration of the underlying asset.
    ///
    /// - Throws: `MediaClipError.invalidTime` if the end time is invalid.
    ///
    public func set(endTime: CMTime) throws {
        guard let startTime = startTime, endTime >= startTime && endTime <= mediaAsset.duration else { throw MediaMemberError.invalidTime }
        self.endTime = endTime
    }
    
    /// Resets the `MediaClip` to having the same duration of the underlying `MediaAsset`.
    ///
    public func resetTrim() {
        startTime = .zero
        endTime = mediaAsset.duration
    }
    
    public func contains(mediaType: AVMediaType) throws -> Bool {
        let asset = try mediaAsset.getAsset()
        return asset.tracks.contains(where: { $0.mediaType == mediaType })
    }
    
    /// Adds the appropriate media to the provided track.
    ///
    /// The type of error thrown will depend on the origin of the problem:
    ///
    /// - `MediaAssetError` - Trouble reading the asset.
    /// - `MediaClipError` - Appropriate media type, as indicated by the track, was not found on the asset.
    /// - `AVError` - Problem inserting the media into the track.
    ///
    /// - Parameters:
    ///     - track: The track into which the clip should be inserted.
    ///     - time: The time offset at which the clip should be inserted.
    ///
    /// - Throws: Various error types if there problems.
    ///
    private func addMedia(to track: AVMutableCompositionTrack, atTime time: CMTime, maxTime: CMTime) throws {
        let asset = try mediaAsset.getAsset()
        guard let clipTrack = asset.tracks.first(where: { $0.mediaType == track.mediaType }) else {
            throw MediaMemberError.mediaTypeNotFound
        }
        try track.insertTimeRange(timeRange, of: clipTrack, at: time)
    }

    /// For given offset percentage provides the start time offset
    public func calculateStartTimeOffset(percent offset: CGFloat) -> CMTime {
        let startTime = CMTimeMultiplyByFloat64(totalDuration, multiplier: Float64(offset))
        return startTime
    }

    /// For given offset percentage provides the end time offset
    public func calculateEndTimeOffset(percent offset: CGFloat) -> CMTime {
        let endTimeStart = CMTimeMultiplyByFloat64(totalDuration, multiplier: Float64(offset))
        return CMTimeSubtract(totalDuration, endTimeStart)
    }
}

extension MediaMember: NSCopying {
    public func copy(with zone: NSZone? = nil) -> Any {
        if self.mediaType == .audio {
            return MediaMember(audioAsset: mediaAsset)
        } else {
            let newMember = MediaMember(media: mediaAsset, isMirrored: isMirrored, rotation: rotation)
            newMember.set(startTime: self.startTime)
            newMember.set(endTime: self.endTime)
            return newMember
        }
    }
}
