import UIKit

public enum ColorPickerStyle {
    case vertical
    case horizontal
}

/// Provides a default color picker control
///
public class ColorPickerControl: UIControl {
    public private(set) var currentOffset: CGFloat = 0

    private let style: ColorPickerStyle
    private var thumbSize: CGFloat {
        smallerEdge
    }

    private let thumbColorSize: CGFloat = 31
    private let largeThumbSize: CGFloat = 55
    private let largeThumbColorSize: CGFloat = 51
    private let largeThumbPadding: CGFloat = 15

    private let colorPalletePadding: CGFloat = 2

    private var currentHue: CGFloat = 0
    private var currentBrightness: CGFloat = 1
    private var currentSaturation: CGFloat = 1
    private let blackWhitePercentage: CGFloat = 0.08
    private let trueWhitePercentage: CGFloat = 0.04
    private let finalColorToBlackPercentage: CGFloat = 0.02
    private var smallerEdge: CGFloat = 20
    private let startHue: CGFloat = 0.75

    private var colorPalleteImageView: UIImageView!
    private var thumbView: UIView!
    private var thumbColorView: UIView!
    private var largeThumbView: UIView!
    private var largeThumbColorView: UIView!
    private var sliderView: UIView!
    private var thumbCenterXConstraint: NSLayoutConstraint?
    private var thumbTopConstraint: NSLayoutConstraint?
    private var largeThumbRightConstraint: NSLayoutConstraint?
    private var panRecognizer: UIPanGestureRecognizer!
    private var tapRecognizer: UITapGestureRecognizer!

    private var needsIntialOffset: Bool = true

    private var colorPalleteImage: UIImage? {
        didSet {
            colorPalleteImageView.image = colorPalleteImage
        }
    }

    var isActive: Bool = false {
        didSet {
            guard isActive && thumbColorView.isHidden || !isActive && !thumbColorView.isHidden else { return }
            thumbColorView.isHidden = !isActive
            let scale: CGFloat = isActive ? 1.0 : 0.7
            thumbColorView.borderColor = isActive ? .white : .clear
            UIView.animate(withDuration: 0.2, animations: {
                self.thumbView.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
            })
        }
    }

    public var currentColor: UIColor! {
        UIColor(hue: currentHue, saturation: currentSaturation, brightness: currentBrightness, alpha: 1)
    }

    private var currentAccessibilityColor: ColorPickerPreset = .red

    public override var accessibilityTraits: UIAccessibilityTraits {
        get {
            [.adjustable, .allowsDirectInteraction]
        }
        set {
            super.accessibilityTraits = newValue
        }
    }

    #warning("handle accessibility")
//    override func accessibilityIncrement() {
//        accessibility(adjustment: .increment)
//    }
//
//    override func accessibilityDecrement() {
//        accessibility(adjustment: .decrement)
//    }
//
//    private func accessibility(adjustment: AccessibilityAdjustment) {
//        let nextColor: ColorPickerPreset
//        switch adjustment {
//        case .decrement:
//            nextColor = currentAccessibilityColor.previous()
//        case .increment:
//            nextColor = currentAccessibilityColor.next()
//        }
//        select(color: nextColor)
//        UIAccessibility.post(notification: .announcement, argument: nextColor.accessibilityLabel)
//        accessibilityLabel = StringBuilder.shared.accessibilityColorPickerSelected(colorString: nextColor.accessibilityLabel)
//        currentAccessibilityColor = nextColor
//    }

    public init(style: ColorPickerStyle) {
        self.style = style
        super.init(frame: CGRect.zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented on ColorPicker")
    }

    private func setup() {
        setupViews()
        setupGestures()
        layoutViews()
        isActive = false
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        if let paletteImage = colorPalleteImage {
            if paletteImage.size.width != bounds.width - colorPalletePadding * 2 {
                setupPalleteImage()
            }
        } else {
            setupPalleteImage()
        }
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        updateColor(withTouches: touches)
    }

    private func setupViews() {
        isAccessibilityElement = true
        accessibilityLabel = "StringBuilder.shared.accessibilityColorPickerSelected(colorString: currentAccessibilityColor.accessibilityLabel)"
        accessibilityHint = "StringBuilder.shared.accessibilityColorPickerHint"
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = InterfaceCommonColors.offBlack.color
        layer.cornerRadius = smallerEdge / 2

        sliderView = UIView()
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        sliderView.layer.cornerRadius = smallerEdge / 2
        addSubview(sliderView)

        colorPalleteImageView = UIImageView()
        colorPalleteImageView.layer.cornerRadius = (smallerEdge - colorPalletePadding * 2) / 2
        colorPalleteImageView.layer.masksToBounds = true
        colorPalleteImageView.borderColor = InterfaceCommonColors.offBlack.color
        colorPalleteImageView.borderWidth = 1
        colorPalleteImageView.contentMode = .scaleAspectFit
        colorPalleteImageView.translatesAutoresizingMaskIntoConstraints = false
        sliderView.addSubview(colorPalleteImageView)

        setupThumbViews()
        clipsToBounds = false
    }

    private func setupThumbViews() {
        thumbView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: thumbSize, height: thumbSize)))
        thumbView.layer.cornerRadius = thumbSize / 2
        thumbView.backgroundColor = .white
        thumbView.translatesAutoresizingMaskIntoConstraints = false
        sliderView.addSubview(thumbView)

        thumbColorView = UIView()
        thumbColorView.layer.cornerRadius = thumbColorSize / 2
        thumbColorView.backgroundColor = currentColor
        thumbColorView.borderWidth = 2
        thumbColorView.translatesAutoresizingMaskIntoConstraints = false
        thumbView.addSubview(thumbColorView)

        largeThumbView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: thumbSize, height: thumbSize)))
        largeThumbView.layer.cornerRadius = largeThumbSize / 2
        largeThumbView.backgroundColor = .white
        largeThumbView.translatesAutoresizingMaskIntoConstraints = false
        sliderView.addSubview(largeThumbView)
        largeThumbView.isHidden = true

        largeThumbColorView = UIView()
        largeThumbColorView.layer.cornerRadius = largeThumbColorSize / 2
        largeThumbColorView.backgroundColor = currentColor
        largeThumbColorView.translatesAutoresizingMaskIntoConstraints = false
        largeThumbView.addSubview(largeThumbColorView)
    }

    private func setupPalleteImage() {
        colorPalleteImage = createPalletImage()
    }

    private func setupGestures() {
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGesture))
        panRecognizer.minimumNumberOfTouches = 1
        panRecognizer.maximumNumberOfTouches = 1
        addGestureRecognizer(panRecognizer)

        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleGesture))
        addGestureRecognizer(tapRecognizer)
    }

    private func layoutViews() {
        if style == .horizontal {
            NSLayoutConstraint.activate([
                heightAnchor.constraint(equalToConstant: smallerEdge),
            ])
        } else {
            NSLayoutConstraint.activate([
                widthAnchor.constraint(equalToConstant: smallerEdge),
            ])
        }

        thumbColorView.layoutCenterEqualToSuperview()
        NSLayoutConstraint.activate([
            thumbColorView.heightAnchor.constraint(equalToConstant: thumbColorSize),
            thumbColorView.widthAnchor.constraint(equalToConstant: thumbColorSize),
        ])

        thumbView.layoutSize(equalTo: thumbSize)
        if style == .horizontal {
            let thumbCenterXConstraint = thumbView.centerXAnchor.constraint(equalTo: leftAnchor)
            NSLayoutConstraint.activate([
                thumbView.centerYAnchor.constraint(equalTo: centerYAnchor),
                thumbCenterXConstraint,
            ])
            self.thumbCenterXConstraint = thumbCenterXConstraint
        } else {
            let thumbTopConstraint = thumbView.topAnchor.constraint(equalTo: topAnchor, constant: colorPalletePadding)
            NSLayoutConstraint.activate([
                thumbView.centerXAnchor.constraint(equalTo: centerXAnchor),
                thumbTopConstraint,
            ])
            self.thumbTopConstraint = thumbTopConstraint
        }

        largeThumbColorView.layoutCenterEqualToSuperview()
        largeThumbColorView.layoutSize(equalTo: largeThumbColorSize)

        largeThumbView.layoutSize(equalTo: largeThumbSize)
        if style == .horizontal {
            NSLayoutConstraint.activate([
                largeThumbView.centerXAnchor.constraint(equalTo: thumbView.centerXAnchor),
                largeThumbView.bottomAnchor.constraint(equalTo: sliderView.topAnchor, constant: -largeThumbPadding),
            ])
        } else {
            let largeThumbRightConstraint = largeThumbView.rightAnchor.constraint(equalTo: sliderView.leftAnchor, constant: -largeThumbPadding)
            NSLayoutConstraint.activate([
                largeThumbView.centerYAnchor.constraint(equalTo: thumbView.centerYAnchor),
                largeThumbRightConstraint,
            ])
            self.largeThumbRightConstraint = largeThumbRightConstraint
        }

        sliderView.layoutEdgesEqualToSuperview()

        colorPalleteImageView.layoutCenterEqualToSuperview()
        let size: CGFloat = smallerEdge - colorPalletePadding * 2
        if style == .horizontal {
            NSLayoutConstraint.activate([
                colorPalleteImageView.heightAnchor.constraint(equalToConstant: size),
                colorPalleteImageView.widthAnchor.constraint(equalTo: widthAnchor, constant: -colorPalletePadding * 2),
            ])
        } else {
            NSLayoutConstraint.activate([
                colorPalleteImageView.widthAnchor.constraint(equalToConstant: size),
                colorPalleteImageView.heightAnchor.constraint(equalTo: heightAnchor, constant: -colorPalletePadding * 2),
            ])
        }
    }

    public func select(color: ColorPickerPreset, notifyDelegate: Bool = true) {
        color.color.getHue(&currentHue, saturation: &currentSaturation, brightness: &currentBrightness, alpha: nil)
        thumbCenterXConstraint?.constant = offset(for: color)
        thumbTopConstraint?.constant = offset(for: color)
        setCurrentColorForViews()
        if notifyDelegate {
            sendActions(for: .valueChanged)
        }
    }

    private func updateFloatingThumb(isSwaped: Bool) {
        let constant = isSwaped ? smallerEdge + largeThumbPadding + largeThumbSize : -largeThumbPadding
        largeThumbRightConstraint?.constant = constant
    }

    public func setIntialColorIfNeeded() {
        if needsIntialOffset {
            select(color: .red, notifyDelegate: false)
            needsIntialOffset = false
        }
    }

    private func offset(for color: ColorPickerPreset) -> CGFloat {
        let palleteSize = style == .vertical ? colorPalleteImageView.bounds.height : colorPalleteImageView.bounds.width
        let colorSize = palleteSize - (palleteSize * blackWhitePercentage * 2) - (palleteSize * trueWhitePercentage) - (palleteSize * finalColorToBlackPercentage)
        switch color {
        case .white:
            return palleteSize
        case .black:
            return colorSize
        case .gray:
            return palleteSize - (palleteSize - colorSize) / 2
        default:
            var offset: CGFloat = currentHue
            if offset < startHue {
                offset = currentHue + (1 - startHue)
            } else {
                offset = 1 - currentHue
            }
            return colorSize * offset
        }
    }

    public func updateColor(toOffset offset: CGFloat) {
        currentOffset = offset
        let thumbOffset = calculateOffset(baseOffset: offset)
        let minValue = smallerEdge / 2 // Handle corner radius hiding some of the edge
        thumbCenterXConstraint?.constant = max(minValue, min(thumbOffset, bounds.width))
        thumbTopConstraint?.constant = min(thumbOffset, bounds.height - thumbSize)

        let total = style == .vertical ? colorPalleteImageView.bounds.height : colorPalleteImageView.bounds.width
        let newColor = getColor(at: thumbOffset, of: total)
        newColor.getHue(&currentHue, saturation: &currentSaturation, brightness: &currentBrightness, alpha: nil)

        setCurrentColorForViews()
        sendActions(for: .valueChanged)
        accessibilityLabel = "StringBuilder.shared.accessibilityColorPicker" // Resetting this back from the preset if used
    }

    private func setCurrentColorForViews() {
        thumbColorView.backgroundColor = currentColor
        largeThumbColorView.backgroundColor = currentColor
    }

    private func getColor(at offset: CGFloat, of colorPickerWidth: CGFloat, whiteAndBlackAsGradients _: Bool = false) -> UIColor {
        var hue: CGFloat = 0
        let saturation: CGFloat
        let brightness: CGFloat

        let trueWhiteWidth = colorPickerWidth * trueWhitePercentage
        let finalColorToBlackWidth = colorPickerWidth * finalColorToBlackPercentage
        let colorWidth = colorPickerWidth - (colorPickerWidth * blackWhitePercentage * 2) - trueWhiteWidth - finalColorToBlackWidth
        let blackWhiteWidth = colorPickerWidth - colorWidth - trueWhiteWidth
        let colorRange = 0 ... colorWidth
        let finalColorToBlackRange = colorWidth ... colorWidth + finalColorToBlackWidth
        let trueWhiteRange = colorWidth + blackWhiteWidth + finalColorToBlackWidth ... colorPickerWidth

        if colorRange.contains(offset) {
            saturation = 1
            brightness = 1
            var hueValue: CGFloat = startHue + offset / colorWidth
            if hueValue >= 1 {
                hueValue = (offset / colorWidth) - (1 - startHue)
            }
            hue = hueValue
        } else if trueWhiteRange.contains(offset) {
            saturation = 0
            brightness = 1
        } else if finalColorToBlackRange.contains(offset) {
            let finalColorToBlackOffset = offset - colorWidth
            saturation = 1
            brightness = 1 - (finalColorToBlackOffset / finalColorToBlackWidth)
            hue = startHue
        } else {
            let blackWhiteOffset = offset - colorWidth - finalColorToBlackWidth
            saturation = 0
            brightness = blackWhiteOffset / blackWhiteWidth
        }
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }

    private func createPalletImage() -> UIImage? {
        let rect = bounds.insetBy(dx: colorPalletePadding, dy: colorPalletePadding)
        let smallestSize = min(rect.height, rect.width)
        let largestSize = max(rect.height, rect.width)

        guard rect.width > .zero else { return nil }
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        for offset in 0 ..< Int(largestSize) {
            let color = getColor(at: CGFloat(offset), of: largestSize, whiteAndBlackAsGradients: true)
            color.set()
            let size: CGSize
            let origin: CGPoint
            if style == .horizontal {
                size = CGSize(width: 1, height: smallestSize)
                origin = CGPoint(x: CGFloat(offset), y: 0)
            } else {
                size = CGSize(width: smallestSize, height: 1)
                origin = CGPoint(x: 0, y: CGFloat(offset))
            }
            let temp = CGRect(origin: origin, size: size)
            UIRectFill(temp)
        }
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    @objc
    private func handleGesture(recognizer: UIGestureRecognizer) {
        switch recognizer.state {
        case .began, .changed, .possible:
            largeThumbView.isHidden = false
        case .failed, .ended, .cancelled:
            largeThumbView.isHidden = true
        @unknown default:
            largeThumbView.isHidden = true
        }
        updateColor(withRecognizer: recognizer)
    }

    private func updateColor(withRecognizer recognizer: UIGestureRecognizer) {
        if style == .horizontal {
            updateColor(toOffset: recognizer.location(in: sliderView).x - thumbSize / 2)
        } else {
            updateColor(toOffset: recognizer.location(in: sliderView).y - thumbSize / 2)
        }
    }

    private func updateColor(withTouches touches: Set<UITouch>) {
        guard let touch = touches.first else {
            return
        }
        if style == .horizontal {
            updateColor(toOffset: touch.location(in: sliderView).x - thumbSize / 2)
        } else {
            updateColor(toOffset: touch.location(in: sliderView).y - thumbSize / 2)
        }
    }

    private func calculateOffset(baseOffset: CGFloat) -> CGFloat {
        let size = style == .horizontal ? colorPalleteImageView.bounds.width : colorPalleteImageView.bounds.height
        return max(0, min(baseOffset, size))
    }

    private func calculateColorOffset(baseOffset: CGFloat) -> CGFloat {
        let size = style == .horizontal ? colorPalleteImageView.bounds.width : colorPalleteImageView.bounds.height
        return max(0, min(baseOffset, size))
    }
}
