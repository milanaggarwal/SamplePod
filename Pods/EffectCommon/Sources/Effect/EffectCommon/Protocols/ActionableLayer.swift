import UIKit
import CameraCommon

/// Enables scale functionality on pinch-zoom
///
public protocol ScalableLayer {
    func scale(withPinchRecognizer recognizer: UIPinchGestureRecognizer, view: UIView)
}

/// Enables rotate functionality on rotate gesture
///
public protocol RotatableLayer {
    func rotate(withRotationRecognizer recognizer: UIRotationGestureRecognizer)
}

/// Enables move functionality on pan gesture
///
public protocol MovableLayer {
    func move(withPanRecognizer recognizer: UIPanGestureRecognizer, view: UIView)
}

/// Enables selection and de-selection capability
///
public protocol SelectableLayer {
    func select()
    func deselect()
}

/// Enables edit capability
///
public protocol EditableLayer {
    func startEditing()
}

/// Provides exposure to add subviews
///
public protocol HasSubViews {
    func subViews() -> [UIView]
    func updateConstraints()
}

/// Enables tranformation of a layer by suporting handling for actions like delete, move & duplicate
///
public protocol TransformationalLayer: AnyObject {
    var actionDelegate : ActionEventDelegate? { get set }
    var coordinateConverter: CoordinateConverter? { get set }
}

/// An actionable layer supports all type of transformation and modifications to a layer
///
public protocol ActionableLayer : TransformationalLayer, ScalableLayer, RotatableLayer, MovableLayer, SelectableLayer {

}

/// Protocol to ensure handling for actions on transform layer
///
public protocol ActionEventDelegate : AnyObject {
    /// Delete the layer
    func delete(layer: TransformLayer)
    /// Duplicate the layer
    func duplicate(layer: TransformLayer)
    /// Move the layer on the zaxis
    func move(layer: TransformLayer, directionisUp: Bool)
}

/// Allow layer to set its own gesture handlers
///
public protocol GesturedLayer {
    func setGestureDelegate(uiGestureRecognizerDelegate: UIGestureRecognizerDelegate, previewView: UIView)
}
