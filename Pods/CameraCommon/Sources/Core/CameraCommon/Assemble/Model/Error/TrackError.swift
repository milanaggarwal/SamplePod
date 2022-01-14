import Foundation

public enum TrackError: Error {
    
    /// The type of the `Member` does not match the type of the `Track`.
    case incorrectMemberType
    
    /// The track's placement rule of `.timeExclusive` or `.gapless` does not allow unbounded Members to be added.
    case cannotAddUnboundedMember
    
    /// The requested time falls outside the boundaries of this `Member`.
    case invalidTime
    
    /// This `.effect` typed track/member cannot be queried for a new media sample.
    case cannotQueryEffectTypeForMedia
    
    /// This `.media` typed track/member cannot apply an effect to a sample.
    case cannotQueryMediaTypeForEffect
    
    /// The attempt to create an `AVAssetTrack` failed.
    case failedToCreateAssetTrack
}
