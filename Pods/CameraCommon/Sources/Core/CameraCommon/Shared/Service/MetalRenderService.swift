import Foundation
import Metal
import MetalKit
import Combine

/// A Metal backed image renderer.
///
/// This is the preferred renderer for all iOS devices featuring an A8 processor or later.
///
public class MetalRenderService: RenderService {
    
    public var preview: UIView { mtkView }
    
    /// The preview view for this renderer is a MTKView.
    private let mtkView: MTKView
    
    /// Store the system metal device.
    private let device: MTLDevice
    
    /// Store the device's command queue.
    private let queue: MTLCommandQueue
    
    /// The Core Image context.
    private let context: CIContext
    
    /// Cached color space.
    private let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
    
    public required init(size: CGSize) throws {
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let queue = device.makeCommandQueue()
        else {
            throw RenderServiceError.failedToCreatePipeline
        }
        self.device = device
        self.queue = queue
        
        self.mtkView = MTKView(frame: CGRect(origin: .zero, size: size), device: device)
        self.mtkView.isPaused = true
        self.mtkView.framebufferOnly = false
        self.mtkView.contentScaleFactor = 1.0
        self.mtkView.translatesAutoresizingMaskIntoConstraints = false
        
        self.context = CIContext(mtlDevice: device)
    }
    
    public func render(image: CIImage, inRect rect: CGRect, to buffer: CVPixelBuffer) -> AnyPublisher<CVPixelBuffer, RenderServiceError> {
        return Deferred {
            Future<CVPixelBuffer, RenderServiceError> { [weak self] promise in
                DispatchQueue.global(qos: .userInitiated).async {
                    guard let self = self else {
                        promise(.failure(RenderServiceError.failedToRenderImage))
                        return
                    }
                    self.context.render(image, to: buffer, bounds: rect, colorSpace: self.colorSpace)
                    promise(.success(buffer))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func render(image: CIImage, to buffer: CVPixelBuffer) {
        context.render(image, to: buffer)
    }
    
    /// Take the steps necessary to make the rendered image appear in the preview view.
    private func renderToScreen(image: CIImage, inRect rect: CGRect) throws {
        guard
            let drawable = mtkView.currentDrawable,
            let buffer = queue.makeCommandBuffer()
        else { throw RenderServiceError.failedToRenderImage }
        
        context.render(image, to: drawable.texture, commandBuffer: buffer, bounds: rect, colorSpace: colorSpace)
        
        buffer.present(drawable)
        buffer.commit()
        mtkView.draw()
    }
}
