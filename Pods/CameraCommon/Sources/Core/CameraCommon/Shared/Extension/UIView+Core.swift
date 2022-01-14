import UIKit

/// Determines which set of constraints in the parent view the child view will be bound to.
public enum ConstraintTarget {
    /// Constraints will be created relative to the parent view's bounds.
    case bounds
    
    /// Constraints will be created relative to the parent view's margins.
    case margins
    
    /// Constraints will be created relative to the parent view's safe area.
    case safeArea
}

public extension UIView {
    /// Add a subview constrained on all sides by the supplied insets.
    ///
    /// - Parameter view: The view to add as a subview.
    /// - Parameter insets: A `UIEdgeInsets` object defining how much inset should be applied to each side of the subview.
    ///
    func addConstrainedSubview(_ view: UIView, insets: UIEdgeInsets, target: ConstraintTarget = .safeArea) {
        addConstrainedSubview(view, top: insets.top, bottom: insets.bottom, leading: insets.left, trailing: insets.right, target: target)
    }
    
    /// Add a subview and apply constraints for non-nil inset parameters.
    ///
    /// - Parameters:
    ///     - view: The view to add as a child.
    ///     - top: The amount to inset the top edge of the child view. If `nil`, no constraint is added.
    ///     - bottom: The amount to inset the bottom edge of the child view. If `nil`, no constraint is added.
    ///     - leading: The amount to inset the leading edge of the child view. If `nil`, no constraint is added.
    ///     - trailing: The amount to inset the bottom edge of the child view. If `nil`, no constraint is added.
    ///
    func addConstrainedSubview(_ view: UIView, top: CGFloat? = nil, bottom: CGFloat? = nil, leading: CGFloat? = nil, trailing: CGFloat? = nil, target: ConstraintTarget = .safeArea) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        switch target {
        case .bounds:
            addViewByBounds(view, top: top, bottom: bottom, leading: leading, trailing: trailing)
        case .margins:
            addViewByLayoutGuide(view, guide: layoutMarginsGuide, top: top, bottom: bottom, leading: leading, trailing: trailing)
        case .safeArea:
            addViewByLayoutGuide(view, guide: safeAreaLayoutGuide, top: top, bottom: bottom, leading: leading, trailing: trailing)
        }
    }
    
    private func addViewByBounds(_ view: UIView, top: CGFloat? = nil, bottom: CGFloat? = nil, leading: CGFloat? = nil, trailing: CGFloat? = nil) {
        if let top = top {
            view.topAnchor.constraint(equalTo: topAnchor, constant: top).isActive = true
        }
        if let bottom = bottom {
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottom).isActive = true
        }
        if let leading = leading {
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leading).isActive = true
        }
        if let trailing = trailing {
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailing).isActive = true
        }
    }
    
    private func addViewByLayoutGuide(_ view: UIView, guide: UILayoutGuide, top: CGFloat? = nil, bottom: CGFloat? = nil, leading: CGFloat? = nil, trailing: CGFloat? = nil) {
        if let top = top {
            view.topAnchor.constraint(equalTo: guide.topAnchor, constant: top).isActive = true
        }
        if let bottom = bottom {
            view.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: bottom).isActive = true
        }
        if let leading = leading {
            view.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: leading).isActive = true
        }
        if let trailing = trailing {
            view.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: trailing).isActive = true
        }
    }
}
