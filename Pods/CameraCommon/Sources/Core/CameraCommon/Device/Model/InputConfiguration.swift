import Foundation

/// This struct configures the input for the IOController.
///
/// The controller will attempt to find cameras with the specified features, but if no
/// match is found, it will go with the default camera for that position instead.
///
public struct InputConfiguration {
        
    /// The resolution that video should be captured at (both cameras).
    public let resolution: VideoResolution
            
    /// Determines whether or not a front-facing camera is included.
    public let includeFrontCamera: Bool
    
    /// An array of features that the front-facing camera should have.
    ///
    /// If no matching camera is found, the default will be used.
    ///
    public let frontCameraFeatures: [MediaSource.Feature]
    
    /// Determines whether or not a back-facing camera is included.
    public let includeBackCamera: Bool
    
    /// An array of features that the back-facing camera should have.
    ///
    /// If no matching camera is found, the default will be used.
    ///
    public let backCameraFeatures: [MediaSource.Feature]
    
    /// Determines whether or not a microphone for audio capture is included.
    public let includeMicrophone: Bool
}

public extension InputConfiguration {
    
    /// The default configuration for Flipgrid.
    static let `default` = InputConfiguration(
        resolution: .halfHD,
        includeFrontCamera: true,
        frontCameraFeatures: [],
        includeBackCamera: true,
        backCameraFeatures: [.virtual],
        includeMicrophone: true
    )
}
