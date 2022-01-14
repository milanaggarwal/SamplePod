import CameraCommon
import CameraTransform
import CoreMedia
import UIKit

/// A transform layer that provides the base functionality of rendering bitmap CIImages as an effect
///
open class BitmapOverlayEffect: TransformLayer {
    
    public var id: UUID = UUID()
    
    public var zIndex: Int = 0
    
    public var isHidden: Bool = false
    
    public var effectType: EffectType
        
    public var debugName: StaticString { effectType.name }
    
    /// The active effect, such as a board, sticker or other type of effect.
    open var activeEffect: CIImage?
    
    /// The size of the image.
    open var size: CGSize
    
    open var orientation: Orientation
    
    open var shouldRemoveLayer: Bool = false
    
    required public init(withSize size: CGSize, orientation: Orientation) {
        self.effectType = .board
        self.size = size
        self.orientation = orientation
    }
    
    /// The UIView configuration supplied for the given TransformLayer. Such as the drag handle of a board.
    open func getConfigurationInterface() -> UIView? { nil }
    
    open func update(withSize size: CGSize, orientation: Orientation, time: CMTime, features: [String : Any]) { }
    
    open func render(withInput image: CIImage) -> CIImage? { nil }
    
    open func shouldBecomeSelected(fromTap point: CGPoint, inRect rect: CGRect) -> Bool {
        return false
    }
    
    open func prepareForRemoval() {
        #warning("Implement this.")
    }
}

extension BitmapOverlayEffect {
    
    /// A method that will move the source CIImage along its y axis based on the provided position.
    public func move(source: CIImage, to point: CGPoint) -> CIImage {
        return source.transformed(by: .init(translationX: point.x, y: point.y))
    }
    
    /// A method that will scale the the given source CIImage to the respective target CIImage.
    public func scale(source: CIImage, to size: CGSize) -> CIImage {
        let sourceSize = source.extent
        
        let width = size.width / sourceSize.width
        let height = size.height / sourceSize.height
        let scale = CGAffineTransform(scaleX: width, y: height)
        
        return source.transformed(by: scale)
    }
}
