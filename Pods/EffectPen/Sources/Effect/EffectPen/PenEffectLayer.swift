import CameraCommon
import CoreMedia
import EffectBitmapOverlay
import EffectCommon
import UIKit

/// A transform layer that provides the functionality of pen effect
///
final class PenEffectLayer: BitmapOverlayEffect, HasSubViews {
    
    /// TransformationalLayer Variables
    public var actionDelegate: ActionEventDelegate?
    public var coordinateConverter: CoordinateConverter?
    
    /// The interaction component.
    private var drawingView: DrawingView?
    private var brushSizeView: UIView = UIView()
    
    /// The Pen used by the drawing layers.
    var pen = Pen()
        
    /// An array of active drawings.
    var lines: [Line] = []

    public required init(withSize size: CGSize, orientation: Orientation) {
        super.init(withSize: size, orientation: orientation)
        self.effectType = .pen
        drawingView = DrawingView(frame: .zero, delegate: self)
        brushSizeView.isHidden = true
    }
    
    public override func update(withSize size: CGSize, orientation: Orientation, time: CMTime, features: [String : Any]) {
        guard let effect = activeEffect else { return }
        activeEffect = scale(source: effect, to: self.size)
    }

    public override func render(withInput image: CIImage) -> CIImage? {
        guard let activeEffect = activeEffect else { return image }
        return activeEffect.composited(over: image)
    }
    
    public override func getConfigurationInterface() -> UIView? {
        return drawingView
    }
    
    public override func prepareForRemoval() {
        super.prepareForRemoval()
        DispatchQueue.main.async {
            self.drawingView?.removeFromSuperview()
        }
    }
    
    public override func shouldBecomeSelected(fromTap point: CGPoint, inRect rect: CGRect) -> Bool {
        guard let drawingView = drawingView, drawingView.frame != .zero else { return false }
        return drawingView.frame.contains(point)
    }
    
    public func subViews() -> [UIView] {
        return [brushSizeView]
    }
    
    func updateConstraints() {
        // do nothing, brush size will handle location on its own
    }
}

// MARK: - Layer Management

extension PenEffectLayer: TransformationalLayer, SelectableLayer, EditableLayer, MovableLayer, ScalableLayer {
    
    func startEditing() {
        if drawingView?.frame == .zero {
            drawingView?.frame = coordinateConverter?.convert(extent: CGRect(origin: .zero, size: self.size)) ?? .zero
        }
    }
    
    func select() { /* do nothing */ }
    
    func deselect() {
        drawingView?.frame = .zero
        drawingView?.removeFromSuperview()
    }
    
    func move(withPanRecognizer recognizer: UIPanGestureRecognizer, view: UIView) {
        guard drawingView?.frame != .zero else { return }
        drawingView?.touch(recognizer: recognizer)
    }

    func scale(withPinchRecognizer recognizer: UIPinchGestureRecognizer, view: UIView) {
        guard drawingView?.frame != .zero else { return }
        drawingView?.updateBrushSize(recognizer: recognizer)

        showBrushSizeView(withSize: CGSize(width: pen.size, height: pen.size), inLocation: recognizer.location(in: view), color: pen.color)

        if recognizer.state == .ended {
            hideBrushSizeView()
        }
        
        recognizer.scale = 1
    }

    private func showBrushSizeView(withSize size: CGSize, inLocation location: CGPoint, color: UIColor) {
        brushSizeView.isHidden = false
        brushSizeView.backgroundColor = color
        brushSizeView.bounds = CGRect(origin: CGPoint.zero, size: size)
        brushSizeView.center = location
        brushSizeView.layer.cornerRadius = size.width / 2
        brushSizeView.dropShadow(shadowOpacity: 0.5, shadowRadius: brushSizeView.layer.cornerRadius, setShadowPath: true)
    }
    
    private func hideBrushSizeView() {
        brushSizeView.isHidden = true
    }
}

// MARK: - DrawingViewDelegate

extension PenEffectLayer: DrawingViewDelegate {
    var isRainbowActive: Bool {
        pen.rainbow.active
    }
  
    /// Sets the activeEffect of the PenEffectLayer.
    func set(image: CIImage) {
        self.activeEffect = image
    }
    
    /// Adds a `Line` to the list of actively stored lines.
    func add(line: Line) {
        lines.append(line)
    }
    
    /// Removes a given `Pen` effect from the stack.
    func remove(line: Line) {
        lines.removeAll(where: { $0.id == line.id })
    }
    
    func size() -> CGSize {
        return self.size
    }
    
    /// Updates the `Pen` color.
    func didUpdate(color: UIColor) {
        pen.color = color
    }

    /// Updates the brush size of the `Pen`.
    func update(penSize: CGFloat) {
        pen.size = penSize
    }
    
    /// Updates the `Rainbow`'s active state.
    func update(rainbowActive: Bool) {
        pen.rainbow.active = rainbowActive
    }
    
    /// Updates the current hue of the `Pen`'s rainbow effect.
    public func update(rainbowHue: CGFloat) {
        pen.rainbow.hue = rainbowHue
    }
}
