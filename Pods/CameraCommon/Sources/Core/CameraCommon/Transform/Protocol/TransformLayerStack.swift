import UIKit
import AVFoundation
import Combine

/// A `LayerStack` manages a list of `TransformLayer` objects and provides methods for controlling
/// their ordering.
public protocol TransformLayerStack: AnyObject {
    
    /// Publishes events that happen in the transform stack
    var layerEventPublisher: AnyPublisher<TransformLayerStackEvent, Never> { get }
        
    /// Add a layer to the stack.
    ///
    /// The layer will be added at the next-highest zIndex. Calling this method with a layer that is already
    /// a member of the stack will have no effect.
    ///
    /// - Parameter layer: The `TransformLayer` to add to the stack.
    ///
    func add(_ layer: TransformLayer)
    
    /// Remove a layer from the stack.
    ///
    /// If the layer is not a member of the stack, then nothing will happen.
    ///
    /// - Parameter layer: The `TransformLayer` to remove from the stack.
    ///
    func remove(_ layer: TransformLayer)
    
    /// Returns whether the specified layer can be moved backward in the stack.
    ///
    /// If the layer cannot be moved backward, either because it is the back-most layer or because it is not a
    /// member of the stack, then the method will return `false`.
    ///
    /// - Parameter layer: The `TransformLayer` to check.
    /// - Returns: `true` if the layer can be moved backward in the stack. Otherwise, returns `false`.
    ///
    func canMoveBackward(_ layer: TransformLayer) -> Bool
    
    /// Returns whether the specified layer can be moved forward in the stack.
    ///
    /// If the layer cannot be moved forward, either because it is the front-most layer or because it is not a
    /// member of the stack, then the method will return `false`.
    ///
    /// - Parameter layer: The `TransformLayer` to check.
    /// - Returns: `true` if the layer can be moved forward in the stack. Otherwise, returns `false`.
    ///
    func canMoveForward(_ layer: TransformLayer) -> Bool
    
    /// Move a layer 1 position back in the stack.
    ///
    /// This will cause the layer to receive update and render calls earlier. If the layer is already the
    /// back-most in the stack, then nothing will happen.
    ///
    /// - Parameter layer: The `TransformLayer` to move backward in the stack.
    ///
    func moveBackward(_ layer: TransformLayer)
    
    /// Move a layer 1 position forward in the stack.
    ///
    /// This will cause the layer to receive update and render calls later. If the layer is already the
    /// front-most in the stack, then nothing will happen.
    ///
    /// - Parameter layer: The `TransformLayer` to move forward in the stack.
    ///
    func moveForward(_ layer: TransformLayer)
    
    /// Move a layer to the back-most position in the stack.
    ///
    /// This will cause the layer to move to the furthest-back position in the stack, if the layer is already
    /// the back-most in the stack, then nothing will happen.
    ///
    /// - Parameter layer: The layer to move to the back of the stack.
    ///
    func moveToBack(_ layer: TransformLayer)
    
    /// Move a layer to the front-most position in the stack.
    ///
    /// This will cause the layer to move to the furthest-forward position in the stack, if the layer is
    /// already the front-most in the stack, then nothing will happen.
    ///
    /// - Parameter layer: The layer to move to the front of the stack.
    ///
    func moveToFront(_ layer: TransformLayer)
    
    /// Swap the positions of 2 layers in the stack.
    ///
    /// If either of the layers are not members of the stack, then nothing will happen.
    ///
    /// - Parameter layer: The first layer to swap.
    /// - Parameter otherLayer: The second layer to swap.
    ///
    func swap(_ layer: TransformLayer, with otherLayer: TransformLayer)
    
    /// Find a layer by its ID value.
    ///
    /// - Returns: The layer with the specified ID or `nil` if no layer with that ID was found.
    ///
    func findLayer(byId id: UUID) -> TransformLayer?
    
    /// Iterate all of the layers in the stack (from back to front) and call their update methods
    /// with the supplied values.
    ///
    /// - Parameters:
    ///     - size: The size of the final rendering target, in pixels.
    ///     - orientation: The current video capture orientation.
    ///     - time: The current recording time.
    ///     - features: The feature dictionary.
    ///
    func update(withSize size: CGSize, orientation: Orientation, time: CMTime, features: [String : Any])
    
    /// Converts the input image into a final output image by applying all layers' transformations to it.
    ///
    /// Layers are called from lowest to highest.
    ///
    /// - Parameter input: The initial image to transform.
    /// - Returns: An image with all layers' transformations applied. If no layers are in the stack, then the
    ///            initial image will be returned.
    ///
    func render(withInput input: CIImage) -> CIImage
    
    /// Checks the layer stack to see if the provided point selects any of the layers.
    ///
    /// Testing runs front-to-back through the stack.
    ///
    /// - Parameter withPoint: The point to test, in UIKit coordinates.
    /// - Parameter inRect: The rectangle the point is relative to, in UIKit coordinates.
    /// - Returns: The first transform layer that indicated it should become selected from the tap or `nil` if none did.
    ///
    func testSelection(withPoint point: CGPoint, inRect rect: CGRect) -> TransformLayer?
}

public enum TransformLayerStackEvent {
    /// Event that is sent when the layer is being added to the stack heirarchy
    case willAdd(TransformLayer)
    /// Event that is sent when the layer is added to the stack heirarchy
    case didAdd(TransformLayer)
    /// Event that is sent when the layer is being removed from stack heirarchy
    case willRemove(TransformLayer)
    /// Event that is sent when the layer is removed from stack heirarchy
    case didRemove(TransformLayer)
}
