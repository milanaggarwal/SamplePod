import CoreImage
import UIKit
import Combine

/// This is the fallback renderer if both Metal is unavailable for some reason.
///
/// It will be *very* slow and is not recommended to apply any effects to the image.
///
public class CPURenderService: RenderService {
    public var preview: UIView { imageView }
    
    private var imageView: UIImageView
    
    private var context: CIContext
    
    private var colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
    
    public required init(size: CGSize) throws {
        imageView = UIImageView(frame: CGRect(origin: .zero, size: size))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        context = CIContext()
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
}
