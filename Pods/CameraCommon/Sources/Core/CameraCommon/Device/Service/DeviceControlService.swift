import AVFoundation
import Combine

/// The `DeviceControlService` manages all interactions with `AVFoundation` to set up and control the
/// device's audio & video hardware.
///
public protocol DeviceControlService: AnyObject {
    
    // MARK: - Capture Setup
        
    /// Attempt to configure the control service with the specified media sources.
    ///
    /// - Parameter mediaSources: The video and/or audio sources to use as the basis of the configuration. If multiple video sources are
    ///                           included, the first will be used initially and the others will be available to cycle to using the
    ///                           `cyclePosition()` method described below.
    ///
    /// - Throws: Throws a `CameraHardwareServiceError` if there was a problem configuring with the provided media sources.
    ///
    /// - Warning: Calling this method will invalidate the current `sampleSource`, causing that source to emit a
    ///            `SampleSourceError.sourceInvalidated` error and then remove all observers.
    ///
    func configure(with mediaSources: [MediaSource]) throws
    
    /// The current SampleSource.
    ///
    /// The sample source is enabled by calling `configure(mediaSources:)`. It emits samples as well as having controls for
    /// starting / stopping the flow of samples.
    ///
    var sampleSource: SampleSource { get }
    
    // MARK: - Live Camera Control
    
    /// Returns whether the currently-active media source is front- or back-facing.
    ///
    /// In audio-only mode, will this will always return `.unspecified`
    ///
    var currentPosition: AVCaptureDevice.Position { get }
    
    /// Indicates whether or not there are alternative `MediaSource`s available to switch to.
    var canCyclePosition: Bool { get }
    
    /// Attempts to cycle between multiple video sources.
    ///
    /// If only 1 source is available, this method will do nothing.
    ///
    /// - Throws: `DeviceControlServiceError.unableToActivateCamera` if cycling to the next camera fails.
    ///
    func cyclePosition() throws
    
    /// Returns the active camera.
    ///
    /// If no camera is currently active, then `nil` is returned.
    ///
    var currentCamera: AVCaptureDevice? { get }
    
    /// Returns the current camera session
    ///
    var session: AVCaptureSession { get }
    
    /// Returns the current camera's zoom range.
    ///
    /// For back-facing, multi-lens cameras, a zoom level of 1 could either be a wide-angle or ultra-wide-angle lens.
    /// If there is no active camera (audio-only mode) then the range will be `0...0`.
    ///
    var zoomRange: ClosedRange<CGFloat> { get }
    
    /// Returns the current zoom level in the range returned by `zoomRange`.
    ///
    /// If there are no cameras active, this will always return `0`. The zoom level will be reset to the default for the
    /// specific camera type when the camera is cycled to. I.E. - Zoom values will not be remembered when cycling cameras.
    ///
    /// - Note: If using this value in conjunction with a `UIPinchGestureRecognizer` to allow user-controlled zooming, the
    ///         value should only be read at the *start* of the gesture and then coninuously multipled with the `scale`
    ///         property of the gesture. Continuously reading this value while zooming will result in extremely erratic behavior.
    ///
    var currentZoom: CGFloat { get }
    
    /// Set the zoom level of the active camera.
    ///
    /// If there are no currently-active cameras, then calling this method does nothing.
    ///
    /// - Parameter zoom: The value to set the zoom to. This value will be clamped to the range returned by `zoomRange`.
    ///
    func set(zoom: CGFloat)
    
    /// Sends a new focal/exposure point to the active camera.
    ///
    /// If no camera is currently active or if the camera rejects the focal point, then calling this method does nothing.
    ///
    /// - Parameter point: The touch-point to focus on. Both the `x` and `y` values will be in the range `0...1`, representing
    ///                    the percentage of the horizontal and vertical height where the touch occurred, measured from the
    ///                    top-left corner of the display. This eliminates the need to directly map from screen coordinates
    ///                    into camera coordinates.
    ///
    func set(focalPoint: CGPoint)
    
    /// Indicates whether the video input on front-facing cameras is mirrored.
    ///
    var isFrontCameraMirrored: Bool { get }
    
    /// Set whether or not front-camera video is mirrored.
    ///
    /// This setting will only come into effect if the front-facing camera indicates that it is capable of mirroring.
    ///
    /// - Parameter isFrontCameraMirrored: The new setting.
    ///
    func set(isFrontCameraMirrored: Bool)
    
    /// Indicates whether the video input on back-facing cameras is mirrored.
    ///
    var isBackCameraMirrored: Bool { get }
    
    /// Set whether or not back-camera video is mirrored.
    ///
    /// This setting will only come into effect if the back-facing camera indicates that it is capable of mirroring.
    ///
    /// - Parameter isBackCameraMirrored: The new setting.
    ///
    func set(isBackCameraMirrored: Bool)
    
    
    // MARK: - Audio Control
    
    /// Publisher for mute value to listen to changes in real time
    var isMutedPublisher: AnyPublisher<Bool, Never> { get }
    
    /// Indicates whether or not input audio is currently muted.
    var isMuted: Bool { get }
    
    /// Sets the mute status of any active microphones.
    ///
    /// If no microphones are active, then calling this method does nothing.
    ///
    /// - Parameter isMuted: A value of `true` will mute microphones. A value of `false` will un-mute them.
    ///
    func set(isMuted: Bool)
    
    // MARK: - Torch Control
    
    /// Indicates whether or not the back-facing light (torch) is currently active.
    ///
    /// If no torch is available, this will always return `false`.
    var isTorchActive: Bool { get }
    
    /// Sets the active state of the torch.
    ///
    /// If the current device has no torch, then calling this method does nothing.
    ///
    /// - Parameter torchIsActive: A value of `true` will turn the torch on. A value of `false` will turn it off.
    ///
    func set(isTorchActive: Bool)
}
