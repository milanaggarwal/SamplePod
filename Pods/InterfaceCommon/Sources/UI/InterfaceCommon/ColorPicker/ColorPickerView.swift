import UIKit

/// Handle color picker actions
///
public protocol ColorPickerViewDelegate: AnyObject {
    var isRainbowActive: Bool { get }
    func didUpdate(color: UIColor)
    func update(rainbowActive: Bool)
}

/// Provides a default color picker view
///
public class ColorPickerView: UIView {
    public private(set) var colorPickerControl: ColorPickerControl?
    private weak var delegate: ColorPickerViewDelegate?
    private let spacing: CGFloat = 6
    private let style: ColorPickerStyle
    private var rainbowButton: UIButton?

    public init(style: ColorPickerStyle, delegate: ColorPickerViewDelegate?, includeRainbowButton: Bool) {
        self.style = style
        self.delegate = delegate
        super.init(frame: .zero)

        if includeRainbowButton {
            setupRainbowButton()
        }
        
        setupColorPicker()
        layoutViews()
        colorPickerControl?.isActive = !includeRainbowButton
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public init(frame _: CGRect) {
        fatalError("init(frame:) not available, please use init(uiConfigurationFactory:)")
    }

    private func setupColorPicker() {
        let colorPickerControl = ColorPickerControl(style: style)
        addSubview(colorPickerControl)
        colorPickerControl.translatesAutoresizingMaskIntoConstraints = false

        colorPickerControl.addTarget(self, action: #selector(colorChanged), for: .valueChanged)
        self.colorPickerControl = colorPickerControl
    }
    
    private func setupRainbowButton() {
        let configuration = IconButtonConfiguration.defaultConfiguration(forType: .rainbow)
        let rainbowButton = OverlayButton(configuration: configuration, displayMode: .light)
        rainbowButton.isSelected = true
        rainbowButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rainbowButton)
        rainbowButton.addTarget(self, action: #selector(rainbowButtonTapped), for: .touchUpInside)
        self.rainbowButton = rainbowButton
    }

    @objc
    private func colorChanged() {
        guard let delegate = self.delegate, let colorPickerControl = self.colorPickerControl else { return }
        colorPickerControl.isActive = true
        rainbowButton?.isSelected = false
        delegate.update(rainbowActive: false)
        delegate.didUpdate(color: colorPickerControl.currentColor)
    }

    @objc
    private func rainbowButtonTapped() {
        guard let delegate = self.delegate, let colorPickerControl = colorPickerControl else { return }
        delegate.update(rainbowActive: !delegate.isRainbowActive)
        rainbowButton?.isSelected = delegate.isRainbowActive
        colorPickerControl.isActive = !colorPickerControl.isActive
        if !delegate.isRainbowActive {
            delegate.didUpdate(color: colorPickerControl.currentColor)
        }
    }

    private func layoutViews() {
        guard let colorPickerControl = self.colorPickerControl else { return }
        let colorPickerConstraints: [NSLayoutConstraint]
        if rainbowButton == nil {
            colorPickerConstraints = [
                colorPickerControl.bottomAnchor.constraint(equalTo: bottomAnchor),
                colorPickerControl.topAnchor.constraint(equalTo: topAnchor),
                colorPickerControl.rightAnchor.constraint(equalTo: rightAnchor),
                colorPickerControl.leftAnchor.constraint(equalTo: leftAnchor),
            ]
        } else {
            if style == .vertical {
                colorPickerConstraints = [
                    colorPickerControl.bottomAnchor.constraint(equalTo: bottomAnchor),
                    colorPickerControl.centerXAnchor.constraint(equalTo: centerXAnchor),
                ]
            } else {
                colorPickerConstraints = [
                    colorPickerControl.rightAnchor.constraint(equalTo: rightAnchor),
                    colorPickerControl.centerYAnchor.constraint(equalTo: centerYAnchor),
                ]
            }
        }
        NSLayoutConstraint.activate(colorPickerConstraints)
        if let rainbowButton = self.rainbowButton {
            let rainbowButtonConstraints: [NSLayoutConstraint]
            if style == .vertical {
                rainbowButtonConstraints = [
                    rainbowButton.topAnchor.constraint(equalTo: topAnchor),
                    rainbowButton.leftAnchor.constraint(equalTo: leftAnchor),
                    rainbowButton.rightAnchor.constraint(equalTo: rightAnchor),
                    rainbowButton.bottomAnchor.constraint(equalTo: colorPickerControl.topAnchor, constant: -spacing),
                ]
            } else {
                rainbowButtonConstraints = [
                    rainbowButton.topAnchor.constraint(equalTo: topAnchor),
                    rainbowButton.leftAnchor.constraint(equalTo: leftAnchor),
                    rainbowButton.bottomAnchor.constraint(equalTo: bottomAnchor),
                    rainbowButton.rightAnchor.constraint(equalTo: colorPickerControl.leftAnchor, constant: -spacing),
                ]
            }
            NSLayoutConstraint.activate(rainbowButtonConstraints)
        }
    }
}
