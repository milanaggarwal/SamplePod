import AVFoundation
import Combine

/// A `AssetController` implementation manages the recorded assets of a `VideoProject`.
///
public protocol AssetController: AnyObject {
    
    /// A closure that is invoked with the result of a fetch operation.
    ///
    /// The result of the fetch operation which will be a `MediaAsset` on success or
    /// a `RecordingControllerError` on failure.
    ///
    typealias FetchCompletion = (Result<MediaAsset, RecordingControllerError>) -> Void
    
    /// The ID of the `Composition` that this controller is working with.
    var id: UUID { get }
    
    /// Whether not  the `AssetController` has an active asset that is being written to.
    var isWriting: Bool { get }
    var isWritingPublisher: AnyPublisher<Bool, Never> { get }
    
    /// Publisher for import video
    var importVideoProgressPublisher: AnyPublisher<ExportProgressEvent, Never> { get }
        
    /// A list of all assets currently managed by this controller.
    ///
    /// This does *not* included deleted assets.
    ///
    var assets: [MediaAsset] { get }
    var assetsPublisher: AnyPublisher<[MediaAsset], Never> { get }
    
    /// A list of all soft-deleted assets.
    var deletedAssets: [MediaAsset] { get }
    var deletedAssetsPublisher: AnyPublisher<[MediaAsset], Never> { get }
        
    /// Returns the total duration of all video assets.
    ///
    /// Will not include the duration of any assets which are soft deleted.
    ///
    var totalVideoDuration: CMTime { get }
    
    /// Creates a new audio or video media asset and makes it available for writing.
    ///
    /// Attempting to create a `MediaType.image` with this method will throw an error, as images cannot be
    /// written to with sample buffers. Use `createAsset(type:from:)` instead.
    ///
    /// - Parameter type: The type of asset being created.
    /// - Parameter fileType: The AVFileType for the given asset being created.
    ///
    /// - Throws: `RecordingSessionControllerError` if the asset cannot be created.
    ///
    func createAsset(type: MediaType, fileType: AVFileType) throws -> MediaAsset
    
    /// Create a media asset from data.
    ///
    /// Media assets created this way will be immediately available and will not be put into a `.writing` status.
    ///
    /// - Parameter type: The type of asset being created.
    /// - Parameter data: The complete data of the asset.
    ///
    /// - Throws: `RecordingControllerError` if the asset cannot be created.
    ///
    func createAsset(type: MediaType, from data: Data) throws -> MediaAsset
    
    /// Fetch an asset from the specified `URL` and create a `MediaAsset` from it.
    ///
    /// - Parameters:
    ///     - type: The type of asset being fetched.
    ///     - url: The `URL` where the asset is located.
    ///     - completion: The completion callback that is invoked upon success or failure.
    func fetchAsset(type: MediaType, from url: URL, completion: @escaping FetchCompletion)
    
    /// Fetch an asset from the specified `URL` and create a `MediaAsset` from it.
    ///
    /// - Parameters:
    ///     - type: The type of asset being fetched.
    ///     - url: The `URL` where the asset is located.
    ///
    /// - Returns: A publisher which will emit either a single `MediaAsset` and complete, or will
    ///            complete with a `RecordingControllerError` on failure.
    ///
    func fetchAsset(type: MediaType, from url: URL) -> AnyPublisher<MediaAsset, RecordingControllerError>
    
    /// Appends a new sample to the active asset.
    ///
    /// - Parameter sample: The sample buffer to write to the active asset.
    /// - Parameter asset: The asset to append to.
    ///
    /// - Throws: `RecordingControllerError` if the asset cannot be written to.
    ///
    func append(sample: CMSampleBuffer, to asset: MediaAsset) throws
    
    /// Finalizes the active asset and closes it.
    ///
    /// Once an asset is finalized, it cannot be written to again and its state will be changed to `.ready`.
    ///
    /// - Parameter asset: The asset to be finalized.
    ///
    /// - Throws: `RecordingControllerError` if the asset cannot be finalized.
    ///
    func finish(asset: MediaAsset, completion: (() -> Void)?) throws
    
    /// Removes the asset from the recording session.
    ///
    /// Assets are "soft" deleted at first, to allow for undo. They will be permenantly deleted when the recording
    /// session is finished.
    ///
    /// - Parameter asset: The asset to delete.
    ///
    /// - Throws: `RecordingControllerError` if the asset cannot be deleted.
    ///
    func delete(asset: MediaAsset) throws
    
    /// Immediately deletes all media assets in the session.
    ///
    /// - Parameter cleanup: When set to `true`, all asset files will be immediately deleted. When `false`, the assets
    ///                      are "soft" deleted, which can be undone.
    ///
    /// - Throws: `RecordingControllerError` if the assets cannot be deleted.
    ///
    func deleteAll(cleanup: Bool) throws
    
    /// Finishes and cleans up the recording session.
    ///
    /// - Returns: The final list of media assets.
    ///
    func finishSession() -> [MediaAsset]
    
    /// Remove export session and stop progress event when cancel button is pressed
    func cancelImportVideo()
}
