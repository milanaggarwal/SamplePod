import UIKit

/// A `NumericMeter` tracks a series of values and displays the average of them.
///
public class NumericMeter<T:Numeric>: UIView {
    
    /// A closure capable of converting a value of type `T` into a string.
    public typealias Formatter = (T) -> String
    
    private var buffer: RollingAverage<T>
    
    /// The longest number seen.
    private var maxDigits: Int = 1
    
    public var label: UILabel = {
        let lbl = UILabel(frame: .zero)
        lbl.font = UIFont.monospacedDigitSystemFont(ofSize: 12.0, weight: .semibold)
        lbl.textColor = UIColor.white
        lbl.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        lbl.textAlignment = .right
        return lbl
    }()
    
    private var labelWidth: NSLayoutConstraint
    
    private let formatter: Formatter
    
    /// Create a new `NumericMeter`.
    ///
    /// - Parameters:
    ///     - bufferDepth: The number of data samples to keep. More samples results in greater "smoothing" of the displayed value.
    ///     - initialValue: The starting average value of the NumericMeter. Defaults to 0.
    ///     - formatter: A closure capable of converting the average value into a string.
    ///
    public init(bufferDepth: Int = 10, initialValue: T = .zero, formatter: @escaping Formatter) {
        buffer = RollingAverage<T>(bufferDepth: bufferDepth, initialValue: initialValue)
        self.formatter = formatter
        label.text = formatter(initialValue)
        labelWidth = label.widthAnchor.constraint(equalToConstant: 0.0)
        labelWidth.isActive = true
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        addConstrainedSubview(label, insets: .zero, target: .bounds)
        updateLabelSize()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("This class does not use init(coder:)")
    }
    
    /// Make sure the label is large enough to display all digits.
    private func updateLabelSize() {
        let labelCount = label.text?.count ?? 1
        guard labelCount > maxDigits else { return }
        maxDigits = labelCount
        label.sizeToFit()
        labelWidth.constant = ceil(label.bounds.size.width)
        label.setNeedsLayout()
    }
}

public extension NumericMeter where T: BinaryInteger {
    /// Add a new value to the meter, which updates the average.
    func add(_ value: T) {
        buffer.add(value)
        label.text = formatter(buffer.average)
        updateLabelSize()
    }
}

public extension NumericMeter where T: FloatingPoint {
    /// Add a new value to the meter, which updates the average.
    func add(_ value: T) {
        buffer.add(value)
        label.text = formatter(buffer.average)
        updateLabelSize()
    }
}
