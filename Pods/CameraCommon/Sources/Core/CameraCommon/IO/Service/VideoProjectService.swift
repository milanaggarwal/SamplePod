import Foundation
import Combine

/// The `VideoProjectService` manages a user's projects, which are a complete description of
/// a single video upload.
///
public protocol VideoProjectService: AnyObject {
    
    /// A closure that handles the results of enumerating available projects.
    typealias AvailableProjectsCompletion = ([VideoProject]) -> Void
    
    /// A closure that receives the result of attempting to create a new recording project.
    typealias CreateProjectCompletion = (Result<VideoProject, VideoProjectServiceError>) -> Void
    
    /// A closure that receives the result of attempting to open a recording project.
    ///
    /// A successful result will return a `RecordingSessionController` capable of interacting with the recording project.
    /// A failure will return a `RecordingSessionServiceError`.
    ///
    typealias OpenCompositionCompletion = (Result<VideoProjectController, VideoProjectServiceError>) -> Void
    
    /// A closure that receives the result of attempting to delete a recording project.
    ///
    /// A successful result has no associated data.
    /// A failure will return a `RecordingSessionServiceError`.
    ///
    typealias DeleteCompositionCompletion = (Result<Void, VideoProjectServiceError>) -> Void
    
    /// Get available recording projects.
    ///
    /// This method works asynchronously and will return results through the completion closure.
    ///
    /// - Parameter completion: The closure which handles the results of the request.
    ///
    func getAvailableCompositions(completion: @escaping AvailableProjectsCompletion)
    
    /// A publisher which emits the latest set of available projects.
    ///
    /// This publisher will never complete and will continue to publish the latest
    /// list of available projects forever.
    ///
    var availableCompositions: AnyPublisher<[VideoProject], Never> { get }
    
    /// Attempts to create a new recording project.
    ///
    /// Returns an instance of `VideoProject`, which can then be used with the `open(project:completion:)` method
    /// to begin interacting with it.
    ///
    /// - Parameter completion: A closure that handles the result of this operation.
    ///
    func createProject(completion: @escaping CreateProjectCompletion)
    
    /// Attempts to create a new recording project.
    ///
    /// - Returns: A publisher which emits a `RecordingSession` on success or a `RecordingSessionServiceError` on failure.
    ///
    func createProject() -> AnyPublisher<VideoProject, VideoProjectServiceError>
    
    /// Attempts to open the specified recording project for modification.
    ///
    /// The completion for this method takes a `Result` type, as this is a failable operation. If the service cannot open the
    /// project, then the reason will be found in the result's error.
    ///
    /// - Parameter project: The `RecordingSession` to open.
    /// - Parameter completion: The closure which will handle the result of this operation.
    ///
    func open(project: VideoProject, completion: @escaping OpenCompositionCompletion)
    
    /// Attempts to open the specified recording project for modification.
    ///
    /// - Parameter project: The `RecordingSession` to open.
    /// - Returns: A publisher which will emit the result of attempting to open the project, either in the form of a
    ///            `RecordingSessionController` capable of interacting with the project on success, or a
    ///            `RecordingSessionServiceError` when the operation fails.
    ///
    func open(project: VideoProject) -> AnyPublisher<VideoProjectController, VideoProjectServiceError>
    
    /// Attempt to delete a recording project and all associated files.
    ///
    /// - Parameter project: The `VideoProject` to delete.
    /// - Parameter completion: The closure which will handle the result of this operation.
    ///
    func delete(project: VideoProject, completion: @escaping DeleteCompositionCompletion)
    
    /// Returns a publisher which emits no values, but will complete with either success or an error depending
    /// on the result of the operation.
    ///
    /// - Parameter project: The `VideoProject` to delete.
    /// - Returns: A publisher that will emit the result of the operation.
    ///
    func delete(project: VideoProject) -> AnyPublisher<Void, VideoProjectServiceError>
}

