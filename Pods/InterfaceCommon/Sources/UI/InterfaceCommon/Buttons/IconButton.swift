import UIKit

/// UIButton used to display image as a button
public class IconButton: UIButton {
    let buttonConfiguration: IconButtonConfiguration
    private var overrideAlphaOnSelect: Bool = true

    private var displayMode: DisplayMode {
        didSet {
            updateDisplay(selected: isSelected)
        }
    }

    private var heightConstraint: NSLayoutConstraint?
    private var widthConstraint: NSLayoutConstraint?
    private var image: UIImage? {
        if displayMode == .light {
            return buttonConfiguration.image
        } else {
            return buttonConfiguration.darkModeImage ?? buttonConfiguration.image
        }
    }

    private var selectedImage: UIImage? {
        if displayMode == .light {
            return buttonConfiguration.selectedImage
        } else {
            return buttonConfiguration.darkModeSelectedImage ?? buttonConfiguration.selectedImage
        }
    }

    private var configurationBackgroundColor: UIColor {
        if displayMode == .light {
            return buttonConfiguration.backgroundColor
        } else {
            return buttonConfiguration.darkModeBackgroundColor ?? buttonConfiguration.backgroundColor
        }
    }

    private var selectedBackgroundColor: UIColor {
        if displayMode == .light {
            return self.buttonConfiguration.selectedBackgroundColor
        } else {
            return self.buttonConfiguration.darkModeSelectedBackgroundColor ?? self.buttonConfiguration.selectedBackgroundColor
        }
    }

    public override var isSelected: Bool {
        willSet(newValue) {
            updateDisplay(selected: newValue)
        }
        didSet {
            updateDisplay(selected: isSelected)
        }
    }

    public override var isHighlighted: Bool {
        willSet(newValue) {
            updateDisplay(selected: newValue)
        }
        didSet {
            updateDisplay(selected: isSelected == true ? true : isHighlighted)
        }
    }

    public override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1 : 0.3
        }
    }

    public init(configuration: IconButtonConfiguration, displayMode: DisplayMode) {
        self.buttonConfiguration = configuration
        self.displayMode = displayMode
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        guard buttonConfiguration.image != nil else {
            return super.imageRect(forContentRect: contentRect)
        }
        let rect = super.imageRect(forContentRect: contentRect)
        let titleRect = self.titleRect(forContentRect: contentRect)

        return CGRect(x: contentRect.width / 2.0 - rect.width / 2.0,
                      y: (contentRect.height - titleRect.height) / 2.0 - rect.height / 2.0,
                      width: rect.width, height: rect.height)
    }

    private func setup() {
        imageView?.contentMode = .scaleAspectFit
        imageEdgeInsets = buttonConfiguration.imageEdgeInsets
        layer.cornerRadius = buttonConfiguration.cornerRadius
        layer.borderWidth = buttonConfiguration.borderWidth
        layer.borderColor = buttonConfiguration.borderColor.cgColor

        showsLargeContentViewer = true
        largeContentTitle = buttonConfiguration.accessibilityLabel
        largeContentImage = image
        addInteraction(UILargeContentViewerInteraction())

        // Check if it exists so we don't override one set in a super class (for instance overlay options)
        if let accessibilityLabel = buttonConfiguration.accessibilityLabel {
            self.accessibilityLabel = accessibilityLabel
        }
        adjustsImageWhenHighlighted = false
        
        translatesAutoresizingMaskIntoConstraints = false
        if buttonConfiguration.width > 0 {
            let widthConstraint = widthAnchor.constraint(equalToConstant: buttonConfiguration.width)
            widthConstraint.priority = .init(999)
            self.widthConstraint = widthConstraint
            NSLayoutConstraint.activate([widthConstraint])
        } else {
            sizeToFit()
        }

        if buttonConfiguration.height > 0 {
            let heightConstraint = heightAnchor.constraint(equalToConstant: buttonConfiguration.height)
            heightConstraint.priority = .init(999)
            self.heightConstraint = heightConstraint
            NSLayoutConstraint.activate([heightConstraint])
        }
        updateDisplay(selected: false)
        NotificationCenter.default.addObserver(self, selector: #selector(displayModeUpdatedToLight), name: DisplayMode.light.notification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(displayModeUpdatedToDark), name: DisplayMode.dark.notification, object: nil)

        clipsToBounds = buttonConfiguration.clipToBounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    func displayModeUpdatedToDark(_: Notification) {
        displayMode = .dark
    }

    @objc
    func displayModeUpdatedToLight(_: Notification) {
        displayMode = .light
    }

    private func updateDisplay(selected: Bool) {
        guard isEnabled else { return }
        backgroundColor = selected ? selectedBackgroundColor : configurationBackgroundColor
        if let image = self.image, let selectedImage = self.selectedImage {
            let currentImage = selected ? selectedImage : image
            setImage(currentImage, for: .normal)
        } else {
            setImage(image, for: .normal)
            if selectedBackgroundColor == configurationBackgroundColor && overrideAlphaOnSelect {
                alpha = selected ? 0.6 : 1
            }
        }
    }
}

public enum DisplayMode: Int {
    case dark
    case light

    var notification: Notification.Name {
        switch self {
        case .dark:
            return Notification.Name("MSCamera.DisplayModeDark")
        case .light:
            return Notification.Name("MSCamera.DisplayModeLight")
        }
    }
}
