import AVFoundation

/// Protocol to enable discvery of media sources availble on the current device
/// 
public protocol DeviceDiscoveryService: AnyObject {
    /// Get all media sources meeting the supplied parameters.
    ///
    /// - Parameters:
    ///     - mediaTypes: Limit sources to those having a media type contained in the array.
    ///                   Pass `nil` to allow all media types.
    ///     - position: The physical position on the device that the media source should have.
    ///                 Pass `nil` to allow all positions.
    ///     - resolution: The capture resolution the media source must support.
    ///                   Pass `nil` to allow all resolutions.
    ///     - features: A list of features that msut **all** be supported by the source.
    ///                 Pass `nil` to allow any features (including no features).
    /// - Returns: An array of `MediaSource` objects that match the provided criteria.
    ///            If no devices meet the criteria, then an empty array will be returned.
    ///
    func getSources(withMediaTypes: [MediaType]?,
                    position: AVCaptureDevice.Position?,
                    resolution: VideoResolution?,
                    features: [MediaSource.Feature]?) -> [MediaSource]
    
    /// Get the (Flipgrid) default front-facing (toward user) camera.
    ///
    /// - Returns: The `MediaSource` for the default front-facing camera, if it could be found.
    ///
    func getDefaultFrontSource() -> MediaSource?
    
    /// Get the (Flipgrid) default back-facing (away from user) camera.
    ///
    /// - Returns: The `MediaSource` for the default back-facing camera, if it could be found.
    ///
    func getDefaultBackSource() -> MediaSource?
    
    /// Get the default microphone.
    ///
    /// Typically, mobile devices only have a single mic.
    ///
    /// - Returns: A `MediaSource` for the microphone, if it could be found.
    ///
    func getDefaultAudioSource() -> MediaSource?
}
