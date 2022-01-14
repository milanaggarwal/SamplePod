import UIKit

// MARK: Shadow

extension UIView {
    public var borderWidth: CGFloat {
        get {
            layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    public var borderColor: UIColor? {
        get {
            UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    public func dropShadow(shadowColor: UIColor? = .black, shadowOpacity: Float = 0.5, shadowOffset: CGSize = CGSize.zero, shadowRadius: CGFloat = 1, setShadowPath: Bool = false) {
        layer.masksToBounds = false
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        if setShadowPath {
            layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        }
    }

    @discardableResult
    public func layoutSize(equalTo constant: CGFloat = 0) -> (heightConstraint: NSLayoutConstraint, widthConstraint: NSLayoutConstraint) {
        translatesAutoresizingMaskIntoConstraints = false
        let heightConstraint = heightAnchor.constraint(equalToConstant: constant)
        let widthConstraint = widthAnchor.constraint(equalToConstant: constant)
        NSLayoutConstraint.activate([
            heightConstraint,
            widthConstraint,
        ])
        return (heightConstraint, widthConstraint)
    }

    public func layoutSize(equalTo size: CGSize) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: size.height),
            widthAnchor.constraint(equalToConstant: size.width),
        ])
    }

    public func layoutEdgesEqualToSuperview(inset: CGFloat = 0) {
        guard let superView = superview else { return }
        layoutEdges(equalTo: superView, inset: inset)
    }

    public func layoutEdges(equalTo view: UIView, inset: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor, constant: inset),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -inset),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset),
        ])
    }

    public func layoutEdgesEqualToSuperview(insets: UIEdgeInsets) {
        guard let superView = superview else { return }
        layoutEdges(equalTo: superView, insets: insets)
    }

    public func layoutEdges(equalTo view: UIView, insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right),
        ])
    }

    public func layoutCenterEqualToSuperview() {
        guard let superView = superview else { return }
        layoutCenter(equalTo: superView)
    }

    public func layoutCenter(equalTo view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}

extension UIColor {
    public func isDark(threshold: Float = 0.28) -> Bool {
        let originalCGColor = cgColor
        let RGBCGColor = originalCGColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)
        guard let components = RGBCGColor?.components else {
            return false
        }

        let brightness = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)
        return (brightness < threshold)
    }
}
