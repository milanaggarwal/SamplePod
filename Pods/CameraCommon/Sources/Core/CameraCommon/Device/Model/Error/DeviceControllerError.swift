/// Errors produced by a `DeviceController`.
///
public enum DeviceControllerError: Error {
    
    /// The controller was unable to find any front-facing camera device.
    ///
    /// This error will only occur when a front-facing camera is required, but none can be found.
    ///
    case unableToFindFrontCamera
    
    /// The controller was unable to find any back-facing camera device.
    ///
    /// This error will only occur when a back-facing camera is required, but none can be found.
    ///
    case unableToFindBackCamera
    
    /// The controller was unable to find a microphone device.
    ///
    /// This error will only occur when a microphone is required, but none can be found.
    ///
    case unableToFindMicrophone
    
    /// The `DeviceController` was unable to create a media source with the specified configuraiton.
    case unableToCreateMediaSource
    
    /// The controller cannot change its configuration while capture is active.
    case cannotConfigureWhileCapturing
}
