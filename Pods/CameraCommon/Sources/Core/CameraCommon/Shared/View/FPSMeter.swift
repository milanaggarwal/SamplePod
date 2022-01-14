import UIKit

final public class FPSMeter: UIView {
    
    
    
    private var prevTimestamp: CFTimeInterval = 0
    
    /// The DisplayLink used to refresh the label text.
    private lazy var displayLink: CADisplayLink = {
        CADisplayLink(target: self, selector: #selector(tick(_:)))
    }()
    
    private var previousTimestamp: CFTimeInterval = 0.0
    
    /// Label that displays the frame rate.
    let meter = NumericMeter<CFTimeInterval>(initialValue: 1.0 / 60.0) { "\(Int(1.0 / $0))" }
    
    /// Pauses the update of the FPS.
    public var isPaused: Bool {
        get { displayLink.isPaused }
        set { displayLink.isPaused = newValue }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        displayLink.add(to: RunLoop.current, forMode: .common)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("Use init(frame:) instead.")
    }
    
    // Unschedule the display link.
    deinit {
        displayLink.invalidate()
    }
        
    /// Add the lable.
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        addConstrainedSubview(meter, insets: .zero, target: .bounds)
    }
    
    /// Update the display based on current timing values.
    ///
    /// - Parameter displayLink: The `CADisplayLink` which is triggered.
    ///
    @objc public func tick(_ displayLink: CADisplayLink) {
        let timestamp = CACurrentMediaTime()
        defer { prevTimestamp = timestamp }
        guard prevTimestamp > 0 else {
            return
        }
        meter.add(timestamp - prevTimestamp)
    }
}
