import UIKit
import CoreImage
import AVFoundation
import Combine

/// Errors produced by a RenderService.
///
public enum RenderServiceError: Error {
    
    /// The render service failed to initialize.
    case failedToCreatePipeline
    
    /// The render service failed to render the image.
    case failedToRenderImage
    
    /// The render service could not lock the buffer base address for rendering.
    case failedToLockBufferBaseAddress
}

/// A `RenderService` renders a CIImage to the screen or a pixel buffer.
///
public protocol RenderService: AnyObject {
    
    /// Returns a MTKView or UIImageView that will display the result of a render call that includes the screen destination.
    var preview: UIView { get }
    
    /// Create a new instance of the `RenderService`.
    ///
    /// - Parameter size: The target rendering size.
    /// - Throws: `RenderServiceError.failedToCreatePipeline` if initialization fails.
    ///
    init(size: CGSize) throws
    
    /// Attempt to render a `CIImage` to the specified destination.
    ///
    /// The publisher is not guaranteed to emit on the main thread, so care must be taken to move the result to
    /// the main thread if necessary.
    ///
    /// - Parameters:
    ///     - image: The CIImage to render.
    ///     - rect: The area of the CIImage to render.
    ///     - buffer: The pixel buffer to output the rendered image to.
    /// - Returns: A publisher which will either emit a sample buffer or a `RenderServiceError`.
    ///
    ///
    func render(image: CIImage, inRect rect: CGRect, to buffer: CVPixelBuffer) -> AnyPublisher<CVPixelBuffer, RenderServiceError>
    
    /// Attempt to render a CIImage on to the buffer
    ///
    /// - Parameters:
    ///     - image: The CIImage to render.
    ///     - buffer: The pixel buffer to output the rendered image to.
    func render(image: CIImage, to buffer:CVPixelBuffer)
}
