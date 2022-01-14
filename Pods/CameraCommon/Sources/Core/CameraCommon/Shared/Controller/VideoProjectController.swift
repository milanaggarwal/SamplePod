import AVFoundation

/// A `CompositionController` provides an interface for interacting with a `VideoProject`.
///
/// It is important to note that this controller only manages the files, represented as `MediaAsset` objects.
/// The concepts of clips, slicing, sequencing, etc. are contained in the `CameraAssemble` framework.
///
public protocol VideoProjectController: AnyObject {
    
    /// Attempt to initialize a `VideoProjectController` with the specified `RecordingSession`.
    ///
    /// - Parameter project: The `VideoProject` this controller will interact with.
    /// - Throws: A `VideoProjectControllerError` if the controller cannot open the project.
    ///
    init(project: VideoProject) throws
    
    /// The `VideoProject` being worked on.
    var project: VideoProject { get }
    
    /// Get a recording controller capable of working with media assets of the `VideoProject`.
    var assetController: AssetController { get }
    
    /// Get a sequencing controller capable of modifying and arranging clips.
    var sequencingController: SequencingController { get }
}
