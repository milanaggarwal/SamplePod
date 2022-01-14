import UIKit
import Photos
import Combine

/// An `IOController` manages all aspects of video input and output.
///
/// Some tasks that the `IOController` assists with:
///
/// - **Composition Management:** CRUD operations on `Compositions` for video creation.
/// - **Device Discovery**: Quickly configure cameras with optional special features such as depth or HDR.
/// - **Device Interaction**: Start and stop video capture, switch between cameras, and set the focal point.
/// - **Library Access:** Access photos and videos from the user's library or send finished videos to it.
/// - **Video Capture:** Either through a camera or from a video file.
/// - **Video Output:** Write to a file, display on screen or create a custom output such as a network stream.
///
public protocol IOController: AnyObject {
    
    var projectService: VideoProjectService { get }
    
    var deviceDiscoveryService: DeviceDiscoveryService { get }
    
    var deviceControlService: DeviceControlService { get }
    
    var mediaLibraryService: MediaLibraryService { get }
    
    var transformController: TransformController? { get set }
    
    var preview: UIView { get }
    
    func setupWithDefaultConfiguration()
    
    func setup(inputConfig: InputConfiguration, outputConfig: OutputConfiguration, transformController: TransformController?)
    
}
