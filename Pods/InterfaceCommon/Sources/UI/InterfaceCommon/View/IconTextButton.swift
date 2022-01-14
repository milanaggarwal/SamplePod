import UIKit

/// A simple button that displays an icon image over text
public class IconTextButton: UIControl {
    static let defaultHighlightedOpacity: CGFloat = 0.6
    
    let showsSelectedState: Bool
    
    /// The image that is displayed in the `iconImageView`
    public var image: UIImage? {
        get {
            iconImageView.image
        }
        set {
            iconImageView.image = newValue
        }
    }
    
    /// The text that will be displayed in the `textLabel`
    public var text: String? {
        get {
            textLabel.text
        }
        set {
            textLabel.text = newValue
        }
    }
    
    /// Set the button to look like it's disabled, while still being enabled
    public var appearsDisabled: Bool = false {
        didSet {
            updateColorForState()
        }
    }
    
    public var disabledOpacity: CGFloat = 0.7
    public lazy var highlightedOpacity: CGFloat = Self.defaultHighlightedOpacity
    
    var textColor: UIColor = .white {
        didSet {
            updateColorForState()
        }
    }
    
    public var highlightedTextColor = UIColor.white.withAlphaComponent(0.7) {
        didSet {
            updateColorForState()
        }
    }
    
    public var selectedTextColor = UIColor.white.withAlphaComponent(0.7) {
        didSet {
            updateColorForState()
        }
    }
    
    public var disabledTextColor = UIColor.white {
        didSet {
            // override disabledOpacity if disabled color is explicitly set
            disabledOpacity = 1.0
            updateColorForState()
        }
    }
    
    public var imageColor: UIColor = .white {
        didSet {
            updateColorForState()
        }
    }
    
    public var highlightedImageColor: UIColor = UIColor.white.withAlphaComponent(0.7) {
        didSet {
            updateColorForState()
        }
    }
    
    public var selectedImageColor: UIColor = .white {
        didSet {
            updateColorForState()
        }
    }
    
    /// Forces the iconImageView to be less than the max size set.
    public var maxImageSize: CGSize? = CGSize(width: 28, height: 28) {
        didSet {
            maxImageSizeUpdated()
        }
    }
    
    public override var isEnabled: Bool {
        didSet {
            updateColorForState()
        }
    }
    
    public override var isHighlighted: Bool {
        didSet {
            updateColorForState()
        }
    }
    
    public override var isSelected: Bool {
        didSet {
            updateColorForState()
        }
    }
    
    public private(set) lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(image: nil)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    public private(set) lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .callout)
        label.minimumScaleFactor = 0.15
        label.adjustsFontForContentSizeCategory = false
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var iconImageContainerView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var selectedBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 1
        view.alpha = 0.0
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 2),
            view.widthAnchor.constraint(equalToConstant: 16),
        ])
        return view
    }()
    
    private lazy var iconMaxWidthConstraint: NSLayoutConstraint = {
        iconImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 48)
    }()
    
    private lazy var iconMaxHeightConstraint: NSLayoutConstraint = {
        iconImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 48)
    }()
    
    private lazy var maxWidthConstraint: NSLayoutConstraint = {
        widthAnchor.constraint(lessThanOrEqualToConstant: 64)
    }()
    
    /// The expected color of the text for the current state
    private var textStateColor: UIColor {
        if isHighlighted {
            return highlightedTextColor
        } else if isSelected {
            return selectedTextColor
        } else {
            return textColor
        }
    }
    
    /// The expected color of the image for the current state
    private var imageStateColor: UIColor {
        if isHighlighted {
            return highlightedImageColor
        } else if isSelected {
            return selectedImageColor
        } else {
            return imageColor
        }
    }
    
    public init(image: UIImage?, text: String?, showsSelectedState: Bool) {
        self.showsSelectedState = showsSelectedState
        super.init(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
        self.text = text
        self.image = image
        setUpView()
    }
    
    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Set's a max width for the button
    /// - Parameters:
    ///   - width: The width that you want the button to be less than
    public func setMaxWidth(width: CGFloat?) {
        guard let width = width else {
            maxWidthConstraint.isActive = false
            textLabel.adjustsFontSizeToFitWidth = false
            textLabel.numberOfLines = 1
            return
        }
        
        maxWidthConstraint.constant = width
        maxWidthConstraint.isActive = true
        
        if text?.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines) != nil {
            // Contains a space or a newline, can cleanly break the text
            textLabel.numberOfLines = 2
        } else {
            // Can't cleanly break, so only give one line
            textLabel.numberOfLines = 1
        }
        textLabel.adjustsFontSizeToFitWidth = true
    }
    
    /// Wraps the text to two lines and trims if unable to fit
    public func wrapAndTrimText() {
        if text?.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines) != nil {
            // Contains a space or a newline, can cleanly break the text
            textLabel.numberOfLines = 2
        } else {
            // Can't cleanly break, so only give one line
            textLabel.numberOfLines = 1
        }
        textLabel.adjustsFontSizeToFitWidth = false
    }
    
    public func set(supportsDynamicType: Bool) {
        textLabel.adjustsFontSizeToFitWidth = supportsDynamicType
        textLabel.font = .preferredFont(forTextStyle: .callout)
    }
    
    private func setUpView() {
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityLabel = text
        isAccessibilityElement = true
        addSubview(iconImageContainerView)
        addSubview(iconImageView)
        addSubview(textLabel)
        if showsSelectedState {
            addSubview(selectedBar)
        }
        set(supportsDynamicType: false)
        addLayoutConstraints()
        maxImageSizeUpdated()
    }
    
    private func addLayoutConstraints() {
        var constraintsToAdd = [
            iconImageContainerView.topAnchor.constraint(equalTo: topAnchor),
            iconImageContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconImageContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            iconImageView.centerYAnchor.constraint(equalTo: iconImageContainerView.centerYAnchor),
            iconImageView.topAnchor.constraint(greaterThanOrEqualTo: iconImageContainerView.topAnchor),
            iconImageView.bottomAnchor.constraint(lessThanOrEqualTo: iconImageContainerView.bottomAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: iconImageContainerView.centerXAnchor),
            iconImageView.leadingAnchor.constraint(greaterThanOrEqualTo: iconImageContainerView.leadingAnchor),
            iconImageView.trailingAnchor.constraint(lessThanOrEqualTo: iconImageContainerView.trailingAnchor),
            
            textLabel.topAnchor.constraint(equalTo: iconImageContainerView.bottomAnchor, constant: 4),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        ]
        
        if showsSelectedState {
            constraintsToAdd.append(contentsOf: [
                selectedBar.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 4),
                selectedBar.centerXAnchor.constraint(equalTo: centerXAnchor),
                selectedBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        } else {
            constraintsToAdd.append(contentsOf: [
                textLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        }
        
        NSLayoutConstraint.activate(constraintsToAdd)
    }
    
    private func maxImageSizeUpdated() {
        guard let size = maxImageSize else {
            iconMaxWidthConstraint.isActive = false
            iconMaxHeightConstraint.isActive = false
            return
        }
        
        iconMaxWidthConstraint.constant = size.width
        iconMaxHeightConstraint.constant = size.height
        iconMaxWidthConstraint.isActive = true
        iconMaxHeightConstraint.isActive = true
    }
    
    private func updateColorForState() {
        if isEnabled {
            alpha = isHighlighted || appearsDisabled ? disabledOpacity : 1.0
        } else {
            alpha = disabledOpacity
        }
        
        textLabel.textColor = isEnabled ? textStateColor : disabledTextColor
        iconImageView.tintColor = isEnabled ? imageStateColor : disabledTextColor
        if showsSelectedState {
            selectedBar.alpha = isSelected ? 1.0 : 0.0
            selectedBar.backgroundColor = isEnabled ? textStateColor : disabledTextColor
        }
    }
}

