/// Errors that can be returned by objects conforming to `MediaLibraryService`.
public enum MediaLibraryServiceError: Error {
    
    /// The user denied access to their media library.
    case noAccessToUserMedia
    
    /// The user opted to cancel their media-picking action.
    case userCancelledPickMedia
    
    /// The service was unable to retrieve the media the user picked.
    case unableToRetrieveMedia
    
    /// The `MediaObject` sent to the `saveToLibrary` was not a photo or video.
    case cannotSaveAudio
}
