import UIKit
import AVFoundation
import Combine
import CameraCommon

/// The default implementation of the TransformController protocol.
/// Holds references to effect layers and handles their rendering.
///
public final class DefaultTransformController: TransformController {
    
    // Protocol conformance.
    
    public var featureManager: FeatureManager
    
    public var layerStack: TransformLayerStack
    
    public var processorStack: BufferProcessorStack
    
    public var renderService: RenderService
    
    public var renderView: UIView { renderService.preview }
        
    // Internal properties.
    
    private var currentSize: CGSize
    
    private var processorSubscription: AnyCancellable? = nil
        
    /// Create an instance of the `DefaultTransformController`
    public init(
        size: CGSize,
        featureManager: FeatureManager = DefaultFeatureManager.shared,
        processorStack: BufferProcessorStack = DefaultBufferProcessorStack(),
        layerStack: TransformLayerStack = DefaultLayerStack(),
        renderService: RenderService? = nil,
        device: Device = UIDevice.current
    ) throws
    {
        self.featureManager = featureManager
        self.processorStack = processorStack
        self.layerStack = layerStack
        self.currentSize = size
        
        if let renderService = renderService {
            // If we're given a render service, use it.
            self.renderService = renderService
        } else {
            // Otherwise, try to construct an appropriate render service.
            if let service = try? MetalRenderService(size: size) {
                self.renderService = service
            } else if let service = try? CPURenderService(size: size) {
                print("WARNING: Using a CPU-based renderer. Effects should be disabled.")
                self.renderService = service
            } else {
                assertionFailure("ERROR: Failed to create ANY renderer. This should never happen.")
                throw TransformControllerError.unableToCreateRenderer
            }
        }
    }
    
    /// Processes a sample buffer and applies it to the specified destination(s).
    ///
    /// - Parameters:
    ///     - buffer: The sample buffer to process.
    ///     - orientation: The current video orientation.
    ///
    /// - Note: The result of this operation will be emitted asynchronously via the delegate method or `samples` Combine publisher.
    ///
    public func transform(buffer: CMSampleBuffer, orientation: Orientation) -> AnyPublisher<CMSampleBuffer, TransformControllerError> {
        
        // Get the time from the sample buffer.
        let time = CMSampleBufferGetPresentationTimeStamp(buffer)
        
        // Call the update method of the layers in the stack.
        layerStack.update(withSize: currentSize, orientation: orientation, time: time, features: featureManager.currentFeatures)
        
        guard !processorStack.isBusy else {
            return Fail(error: TransformControllerError.controllerIsBusy).eraseToAnyPublisher()
        }
        return processorStack.process(buffer: buffer, orientation: orientation)
            .mapError { _ in TransformControllerError.unableToRenderBuffer }
            .flatMap { buffer in
                self.render(buffer: buffer, orientation: orientation)
            }
            .eraseToAnyPublisher()
    }
    
    /// Take the CMSampleBuffer and apply any transformation layers to it, render the transformed image,
    /// then send the result to the specified destination.
    ///
    /// - Parameters:
    ///     - buffer: The `CMSampleBuffer` to render.
    ///     - orientation: The video orientation.
    ///
    private func render(buffer: CMSampleBuffer, orientation: Orientation) -> AnyPublisher<CMSampleBuffer, TransformControllerError> {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(buffer) else {
            return Just(buffer)
                .setFailureType(to: TransformControllerError.self)
                .eraseToAnyPublisher()
        }
        CVPixelBufferLockBaseAddress(imageBuffer, [])
        let inputImage = CIImage(cvImageBuffer: imageBuffer)
        #warning("Add orientation support") // Revert https://github.com/flipgrid/fg_camera_core_ios/pull/70
        let finalImage = layerStack.render(withInput: inputImage)
        
        let id = Logger.shared.startPerformanceTrace(label: "transform-render-final-image")
        let size = CVImageBufferGetDisplaySize(imageBuffer)
        return renderService.render(image: finalImage, inRect: CGRect(origin: .zero, size: size), to: imageBuffer)
            .compactMap { pixelBuffer in self.wrap(buffer: pixelBuffer, originalBuffer: buffer) }
            .mapError({ _ in TransformControllerError.unableToRenderBuffer })
            .handleEvents(receiveCompletion: { _ in
                CVPixelBufferUnlockBaseAddress(imageBuffer, [])
                Logger.shared.endPerformanceTrace(id: id)
            })
            .eraseToAnyPublisher()
    }
    
    /// Create a CMSampleBuffer from a CVPixelBuffer using the settings from the originating sample buffer.
    ///
    /// - Parameter buffer: The modified CVPixelBuffer.
    /// - Parameter originalBuffer: The original CMSampleBuffer, used to copy over metadata.
    /// - Returns A new CMSampleBuffer or `nil` if creation was unsuccessful.
    ///
    private func wrap(buffer: CVPixelBuffer, originalBuffer: CMSampleBuffer) -> CMSampleBuffer? {
        guard
            let format = CMSampleBufferGetFormatDescription(originalBuffer),
            let originalPixelBuffer = CMSampleBufferGetImageBuffer(originalBuffer)
        else { return nil }
        var timingInfo = CMSampleTimingInfo(duration: CMSampleBufferGetDuration(originalBuffer),
                                            presentationTimeStamp: CMSampleBufferGetPresentationTimeStamp(originalBuffer),
                                            decodeTimeStamp: CMSampleBufferGetDecodeTimeStamp(originalBuffer))
        var newSampleBuffer: CMSampleBuffer? = nil
        // Copy the attachments or the call to
        originalPixelBuffer.propagateAttachments(to: buffer)
        // Create the new sample buffer.
        let result = CMSampleBufferCreateReadyWithImageBuffer(allocator: kCFAllocatorDefault,
                                                              imageBuffer: buffer,
                                                              formatDescription: format,
                                                              sampleTiming: &timingInfo,
                                                              sampleBufferOut: &newSampleBuffer)
        guard result == 0 else { return originalBuffer }
        return newSampleBuffer
    }
    
    private func fit(_ image: CIImage, to size: CGSize) -> CIImage {
        let imageSize = image.extent.size
        let scaleW = size.width / imageSize.width
        let scaleH = size.height / imageSize.height
        let scale = max(scaleW, scaleH)
        let width0 = imageSize.width * scale
        let height0 = imageSize.height * scale
        let dx = (size.width - width0) / 2.0
        let dy = (size.height - height0) / 2.0
        let transform = CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: dx, y: dy)
        return image
            .transformed(by: transform)
            .cropped(to: CGRect(origin: .zero, size: size))
    }
}

private extension CGSize {
    var flipped: CGSize { CGSize(width: self.height, height: self.width) }
}
