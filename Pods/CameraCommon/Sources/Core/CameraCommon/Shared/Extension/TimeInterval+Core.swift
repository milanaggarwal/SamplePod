import AVFoundation

extension TimeInterval {
    
    /// The preferred timescale for videos.
    static let preferredVideoTimescale: Int32 = 600
    
    /// The preferred timescale for audio samples.
    static let preferredAudioTimescale: Int32 = 44_100
    
    /// Converts the `TimeInterval` into a `CMTime` scaled appropriately for video timing.
    ///
    var videoCMTime: CMTime { CMTimeMakeWithSeconds(self, preferredTimescale: TimeInterval.preferredVideoTimescale) }
    
    /// Converts the `TimeInterval` into a `CMTime` scaled appropriately for audio timing.
    ///
    var audioCMTime: CMTime { CMTimeMakeWithSeconds(self, preferredTimescale: TimeInterval.preferredAudioTimescale) }
}
