import UIKit
import InterfaceCommon

protocol DrawingViewDelegate: ColorPickerViewDelegate {
    var lines: [Line] { get }
    var pen: Pen { get }
    func add(line: Line)
    func remove(line: Line)
    func set(image: CIImage)
    func update(rainbowHue: CGFloat)
    func update(penSize: CGFloat)
}

class DrawingViewModel {
    
    /// Delegate
    private weak var delegate: DrawingViewDelegate?
    
    private let view: DrawingView
    private var currentLine: Line?
    private var drawing: UIImage?
    public var isDrawing: Bool = false
    
    public init(view: DrawingView, delegate: DrawingViewDelegate?) {
        self.view = view
        self.delegate = delegate
    }
    
}

// MARK: - Gesture Recognizers
extension DrawingViewModel {
    
    /// Touch events routed to this method will call draw.
    public func handleTouch(recognizer: UIGestureRecognizer) {
        let point = recognizer.location(in: view)
        
        updateRainbowColor()
        
        switch recognizer.state {
        case .began:
            beginLine(at: point)
        case .changed:
            continueLine(to: point)
        case .ended, .cancelled, .failed:
            endLine()
        default:
            break
        }
        
        draw()
    }
    
    /// Pinch Gestures will scale the pen effect up/down accordingly.
    public func updateBrushSize(recognizer: UIPinchGestureRecognizer) {
        guard let pen = delegate?.pen else { return }
        let scale = recognizer.scale
        
        var scaleToUse = scale
        if scale > 1 {
            scaleToUse *= pen.scaleFactor
        } else {
            scaleToUse /= pen.scaleFactor
        }
        
        delegate?.update(penSize: min(max(pen.size * scaleToUse, pen.minSize), pen.maxSize))
    }
    
    /// If the rainbow effect is active, we constantly update the hue to cycle through rainbow colors.
    private func updateRainbowColor() {
        guard let delegate = delegate, delegate.pen.rainbow.active else { return }
        
        var currentHue = delegate.pen.rainbow.hue
        
        var hue = currentHue + 0.005
        if hue > 1 {
            hue = 0
        }
        currentHue = hue
        
        delegate.update(rainbowHue: currentHue)
        delegate.didUpdate(color: UIColor(hue: currentHue, saturation: 1, brightness: 1, alpha: 1))
    }
}

// MARK: - Drawing/Line Management
extension DrawingViewModel {
    
    /// Shows/hides the animatable view when we are drawing/stop drawing.
    private func animate(hidden: Bool) {
        let alpha: CGFloat = hidden ? 0.0 : 1.0
        
        UIView.animate(withDuration: 0.2) {
            self.view.alpha = alpha
            self.view.isUserInteractionEnabled = !hidden
        }
    }

    /// Begins the line at the given point, initializes a new Line object.
    private func beginLine(at point: CGPoint) {
        guard let pen = delegate?.pen else { return }
        isDrawing = true
        animate(hidden: true)

        let point = Point(point: point, color: pen.color.cgColor, size: pen.size)
        let newLine = Line(points: [point, point])
        
        currentLine = newLine
    }
    
    /// Continues the line, by pulling in the current `Line` and `Pen` properties.
    private func continueLine(to point: CGPoint) {
        guard let pen = delegate?.pen, let line = currentLine else { return }
        
        let point = Point(point: point, color: pen.color.cgColor, size: pen.size)
        line.points.append(point)
    }
    
    /// Finalizes the `Line` and adds it to the list of available lines.
    private func endLine() {
        if let line = currentLine {
            delegate?.add(line: line)
        }
        animate(hidden: false)
        currentLine = nil
        isDrawing = false
    }
    
    /// Draws the lines on the canvas, this also pulls in any existing `Line` objects from the delegate.
    private func draw() {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setLineCap(.round)
        context.setBlendMode(.normal)
        
        // Draw any existing lines onto the canvas first, this ensures they don't cover the new line.
        if let lines = delegate?.lines {
            for line in lines {
                let range = 0 ..< (line.points.count - 1)
                for i in range {
                    let point = line.points[i]
                    let nextPoint = line.points[i + 1]
                    context.setStrokeColor(point.color)
                    context.setLineWidth(point.size)
                    context.addLines(between: [point.point, nextPoint.point])
                    context.strokePath()
                }
            }
        }
        
        // Draw the new line onto the canvas.
        if let line = currentLine {
            let pointIndexRange = 0 ..< (line.points.count - 1)
            for i in pointIndexRange {
                let point = line.points[i]
                let nextPoint = line.points[i + 1]
                context.setStrokeColor(point.color)
                context.setLineWidth(point.size)
                context.addLines(between: [point.point, nextPoint.point])
                context.strokePath()
            }
        }
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            guard let ciImage = CIImage(image: image) else { return }
            self.drawing = image
            delegate?.set(image: ciImage)
        }
        
        UIGraphicsEndImageContext()
    }
}
