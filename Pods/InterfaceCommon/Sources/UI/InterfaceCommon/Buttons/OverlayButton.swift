import UIKit

public class OverlayButton: RoundedButton {
    var index: Int = 0
    private var colorView: UIView?
    private var gradientLayer: CAGradientLayer?
    private var image: UIImage?
    private var selectedImage: UIImage?
    
    private let colorViewSize = CGSize(width: 40, height: 26)
    private let selectedBackgroundColor = UIColor.white
    
    init(configuration: IconButtonConfiguration, displayMode: DisplayMode, colors: [UIColor]? = nil) {
        super.init(configuration: configuration, displayMode: displayMode)
        if let colors = colors {
            update(withColors: colors)
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        if let colorView = self.colorView {
            gradientLayer?.frame = colorView.bounds
        }
    }

    private func updateDisplay(selected: Bool) {
        backgroundColor = selected ? buttonConfiguration.selectedBackgroundColor : buttonConfiguration.backgroundColor
        var showImage = colorView == nil
        if let colorView = self.colorView, colorView.isHidden {
            showImage = true
        }
        if showImage {
            let currentImage = isSelected ? selectedImage : image
            setImage(currentImage, for: .normal)
        }
    }

    private func setupColorView() {
        let colorView = UIView(frame: .zero)
        colorView.isUserInteractionEnabled = false
        colorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(colorView)
        colorView.layoutEdgesEqualToSuperview()
        self.colorView = colorView
    }

    private func setupGradientLayer(withColors colors: [UIColor]) {
        if let colorView = self.colorView {
            let gradientLayer = CAGradientLayer()
            var locations = [NSNumber]()
            for i in 0 ..< colors.count {
                let location = Float(i) / Float(colors.count - 1)
                locations.append(NSNumber(value: location))
            }
            gradientLayer.locations = locations
            gradientLayer.colors = colors.map(\.cgColor)
            gradientLayer.cornerRadius = colorView.layer.cornerRadius
            self.colorView?.layer.addSublayer(gradientLayer)
            self.gradientLayer = gradientLayer
        }
    }

    func update(withColors colors: [UIColor]) {
        setImage(nil, for: .normal)
        if colorView == nil {
            setupColorView()
        }
        if colors.count == 1, let color = colors.first {
            colorView?.backgroundColor = color
            gradientLayer?.removeFromSuperlayer()
            gradientLayer = nil
        } else {
            if gradientLayer == nil {
                setupGradientLayer(withColors: colors)
            } else {
                gradientLayer?.colors = colors.map(\.cgColor)
            }
        }
        colorView?.isHidden = false
    }

    func update(withImage image: UIImage, selectedImage: UIImage, color: UIColor? = nil) {
        colorView?.isHidden = true
        self.image = image
        self.selectedImage = selectedImage

        let currentImage = isSelected ? selectedImage : image
        setImage(currentImage, for: .normal)
        imageView?.contentMode = .scaleAspectFit
        tintColor = color
    }
}
