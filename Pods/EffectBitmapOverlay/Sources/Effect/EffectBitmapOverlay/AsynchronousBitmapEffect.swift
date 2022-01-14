import Combine
import CoreImage

/// Provides configuration ability to a bitmap effect to load its image asynchornously
///
public protocol AsynchronousBitmapEffect {
    var effectPublisher : AnyPublisher<CIImage?, Never> { get }
}
