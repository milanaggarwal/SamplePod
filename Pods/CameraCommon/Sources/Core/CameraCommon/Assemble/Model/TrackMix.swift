import AVFoundation

/// Bundles up functional components that encapsulate the current project state.
///
/// This object can be used to configure either an `AVPlayerItem` for video playback
/// or an `AVAssetExportSession` for final export of the movie.
///
public struct TrackMix {
    
    /// The asset containing all media.
    public let asset: AVAsset
    
    /// An optional audio mix that allows the mixing of multiple audio tracks.
    public let audioMix: AVAudioMix?
    
    /// An optional video composition that allows the application of effects to video as it is displayed or exported.
    public let videoComposition: AVVideoComposition?
    
    /// Generate an `AVPlayerItem` from the `TrackMix`.
    ///
    public func getPlayerItem() -> AVPlayerItem {
        let item = AVPlayerItem(asset: asset)
        item.audioMix = audioMix
        item.videoComposition = videoComposition
        return item
    }
    
    /// Generate an `AVAssetExportSession` from the `TrackMix`.
    ///
    /// - Parameter preset: The `AVAssetExportPreset` to initialize the export session with.
    ///
    /// - Returns: The configured `AVAssetExportSessoin` on success or `nil` on failure.
    ///
    public func getExportSession(preset: String = AVAssetExportPresetHighestQuality) -> AVAssetExportSession? {
        guard let session = AVAssetExportSession(asset: asset, presetName: preset) else { return nil }
        session.audioMix = audioMix
        session.videoComposition = videoComposition
        return session
    }
}
