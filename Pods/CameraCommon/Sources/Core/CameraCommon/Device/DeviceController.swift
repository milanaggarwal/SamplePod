import Foundation

/// An object conforming to `DeviceController` is able to discover and interact with the various media input
/// hardware found on the user's device.
///
public protocol DeviceController: AnyObject {
    
    /// The service used to discover capture hardware.
    ///
    /// There should be little reason to interact with this service directly, as the `DeviceController` will
    /// handle the setup based on the input configuration.
    ///
    var discoveryService: DeviceDiscoveryService { get }
    
    /// The service used to control the individual devices.
    ///
    /// This service contains all of the functionality for changing the configuration of the camera, including:
    ///
    /// - Cycle between available cameras
    /// - Set focal point
    /// - Set zoom level
    /// - Set mute
    /// - Turn torch on and off
    ///
    var controlService: DeviceControlService { get }
    
    /// Indicates whether or not the controller is currently capturing audio or video.
    ///
    /// Capture must be stopped when attempting to set a new configuration.
    ///
    var isCapturing: Bool { get }
    
    /// Get the current sample source.
    ///
    /// The `sampleSource` provides the controls for starting/stopping the flow of samples as well as
    /// emitting the samples themselves.
    ///
    /// - Note: This property will be `nil` until `setup(configuration:)` is called.
    ///
    var sampleSource: SampleSource? { get }
    
    /// Attempts to configure the device for capture using the parameters provided.
    ///
    /// If the device is unable to find an input with all of the requested features, it will
    /// fall back to using the default input for the requested resolution.
    ///
    /// - Parameter configuration: The configuration the device will attempt to use.
    ///
    /// - Throws: A `DeviceControllerError` if the controller failed to apply the desired configuration.
    ///
    func setup(with configuration: InputConfiguration) throws
}
