import Foundation
import Combine
import AVFoundation

/// The `TrackController` manages tracks and ensures that they are sampled in the correct order.
///
public protocol TrackController: AnyObject {
    
    /// Get a publisher that contains the current list of tracks.
    var allTracks: AnyPublisher<[Track], Never> { get }
    
    /// Get a publisher for the media tracks in the controller.
    var mediaTracks: AnyPublisher<[MediaTrack], Never> { get }
    
    /// Get a publisher for the effect tracks in the controller.
    var effectTracks: AnyPublisher<[EffectTrack], Never> { get }
    
    /// Get the current tracks.
    var currentTracks: [Track] { get }
    
    /// Updates whenever the maximum track length changes.
    var duration: AnyPublisher<CMTime, Never> { get }
    
    /// Get a snapshot of the current maximum duration.
    var currentDuration: CMTime { get }
    
    /// Add a track to the `TrackController`.
    func addTrack(_ track: Track)
    
    /// Remove a track from the `TrackController`.
    func removeTrack(_ track: Track)
    
    /// Get all tracks of a particular type.
    func tracks(of type: Track.TrackType) -> [Track]
    
    /// Shortcut to access tracks that supply a particular media type.
    ///
    /// - Parameter type: The type of media to find.
    /// - Returns: A list of matching tracks.
    /// 
    func mediaTracks(of type: MediaTrack.MediaType) -> [MediaTrack]
    
    /// Attempt to create the `TrackMix` for the current set of tracks.
    ///
    /// - Throws: `TrackControllerError` if the mix could not be created.
    /// - Returns: The created `TrackMix`.
    /// 
    func getTrackMix() throws -> TrackMix
}
