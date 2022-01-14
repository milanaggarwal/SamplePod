import Foundation
import CoreMedia
import Combine
import AVFoundation

/// A track sequences members in time.
///
open class MediaTrack: Track {
    
    /// The media type of this track.
    public enum MediaType: Codable, Equatable {
        
        /// The track contains video.
        case video
        
        /// The track contains audio/music.
        case audio
    }
    
    /// The type of media that the `Track` hosts.
    public let mediaType: MediaType
    
    /// The relative volume of this track's audio component in the final mix.
    public var volume: Float = 1.0
    
    private var mediaMembers: [MediaMember] {
        currentMembers.compactMap { $0 as? MediaMember }
    }
    
    /// Create a new track.
    public init (id: UUID = UUID(), mediaType: MediaType, behavior: PlacementBehavior) {
        self.mediaType = mediaType
        super.init(id: id, type: .media, behavior: behavior)
    }
    
    override public func addAtClosestValidTime(_ member: Member) throws {
        guard
            let media = member as? MediaMember,
            media.mediaType == mediaType
        else { throw TrackError.incorrectMemberType }
        try super.addAtClosestValidTime(media)
    }
    
    /// Add all of the media organized by this track to the provided composition.
    ///
    /// - Parameters:
    ///     - composition: The composition to add this track's content to.
    ///     - duration: The overall duration of the composition.
    ///     - audioMix: The audio mix object which will control this track's audio volume.
    ///
    /// - Throws: `TrackError` if the track could not be added to the composition.
    ///
    public func addTrack(to composition: AVMutableComposition, audioMix: AVMutableAudioMix) throws {
        
        // Total duraton of all members in track
        let duration = totalDuration
        // Iterate over this media track's media types.
        let mediaTypes: [AVMediaType]
        
        switch mediaType {
        case .video:
            mediaTypes = [.video, .audio]
        case .audio:
            mediaTypes = [.audio]
        }
        let workingMembers = mediaMembers
        try mediaTypes
            .map { mediaType -> AVMutableCompositionTrack in
                guard let track = composition.addMutableTrack(withMediaType: mediaType, preferredTrackID: composition.unusedTrackID()) else {
                    throw TrackError.failedToCreateAssetTrack
                }
                if mediaType == .audio {
                    audioMix.inputParameters.append(getAudioInputParameters(for: track, duration: duration))
                }
                return track
            }
            .forEach { track in
                var startTime = CMTime.zero
                try workingMembers.forEach {
                    let currentDuration = $0.duration
                    try $0.add(to: track, atTime: startTime, maxTime: duration)
                    startTime = startTime + currentDuration
                }
            }
    }
    
    /// Constructs an audio mix for this track's audio.
    ///
    /// This is included as an `open` method so that subclasses can include custom audio behaviors such as
    /// fade-in or fade-out.
    ///
    /// - Parameter track: The audio track to create an audio mix for.
    ///
    /// - Returns: The configured `AVAudioMixInputParameters` object.
    /// 
    open func getAudioInputParameters(for track: AVCompositionTrack, duration: CMTime) -> AVAudioMixInputParameters {
        let params = AVMutableAudioMixInputParameters(track: track)
        params.setVolume(volume, at: .zero)
        return params
    }
}

