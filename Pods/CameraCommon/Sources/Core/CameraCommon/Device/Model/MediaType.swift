import AVFoundation

/// Indicates the general type of a piece of media.
public enum MediaType: String, Hashable, Equatable, Codable {
    
    /// The media is a still image.
    case image
    
    /// The media is video.
    case video
    
    /// The media is audio.
    case audio
    
    /// The media is some other format (depth, closed captioning, etc.)
    case other
}
