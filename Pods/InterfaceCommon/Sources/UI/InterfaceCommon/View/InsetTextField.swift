import UIKit

/// `UITextField` that has a customizable padding
open class InsetTextField: UITextField {
    
    var padding = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6) {
        didSet {
            setNeedsLayout()
        }
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
