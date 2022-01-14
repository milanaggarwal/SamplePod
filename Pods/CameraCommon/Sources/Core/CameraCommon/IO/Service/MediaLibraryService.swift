import Combine

/// An object conforming to `MediaLibraryService` provides access to the user's photos and videos.
///
public protocol MediaLibraryService: AnyObject {
    
    /// A closure which receives the result of a user picking media.
    typealias PickMediaCompletion = (Result<MediaAsset, MediaLibraryServiceError>) -> Void
    
    /// A closure which receives the result of attempting to save to the user's media library.
    typealias SaveMediaCompletion = (Result<Void, MediaLibraryServiceError>) -> Void
    
    /// If the user has not yet granted access to their media library, calling this method will immediately make the request.
    func requestLibraryAccess()
        
    /// Allow the user to pick a media asset from their library.
    ///
    /// - Parameters:
    ///     - type: Filters the type of media the user is allowed to pick.
    ///     - completion: The callback which is invoked with the result of the picking operation.
    ///
    func pickVisualMedia(type: VisualMediaPickerType, completion: @escaping PickMediaCompletion)
    
    /// Allow the user to pick a media asset from their library.
    ///
    /// - Parameter type: The type of media the user is allowed to pick.
    /// - Returns: A Combine publisher which will emit a single MediaObject result or an error.
    ///
    func pickVisualMedia(type: VisualMediaPickerType) -> AnyPublisher<MediaAsset, MediaLibraryServiceError>
    
    /// Allows the user to pick an audio file.
    ///
    /// - Parameter completion: The callback which is invoked with the result of the picking operation.
    ///
    func pickAudio(completion: PickMediaCompletion)
    
    /// Allows the user to pick an audio file.
    ///
    /// - Returns: A Combine publisher which will emit a single MediaObject result or an error.
    ///
    func pickAudio() -> AnyPublisher<MediaAsset, MediaLibraryServiceError>
    
    /// Save a photo or video to the media library.
    ///
    /// - Parameter media: The media object to save to the user's library.
    /// - Parameter completion: The callback which is invoked with the result of the save operation.
    /// - Throws: `MediaLibraryServiceError.cannotSaveAudio` if `media` is an audio file.
    ///
    func saveToLibrary(_ media: MediaAsset, completion: @escaping SaveMediaCompletion) throws
    
    /// Save a photo or video to the media library.
    ///
    /// - Parameter media: The media object to save to the user's library.
    /// - Returns: A publisher which will emit no value on success or an `NSError` on failure.
    /// - Throws: `IOControllerError.cannotSaveAudio` if `media` is an audio file.
    ///
    func saveToLibrary(_ media: MediaAsset) throws -> AnyPublisher<Void, MediaLibraryServiceError>

}
