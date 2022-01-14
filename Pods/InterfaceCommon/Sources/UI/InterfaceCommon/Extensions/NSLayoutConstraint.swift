import UIKit

extension NSLayoutConstraint {
    /// Returns the constraint updated with the given priority
    ///
    /// - Parameter priority: The priority to be set.
    /// - Returns: The updated constraint.
    public func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}

// MARK: - Convenience Priorities

extension UILayoutPriority {
    /// A layout priority that is one step below `.required`
    /// Useful for when the debugger prints out constraint panic for view with `.zero` frames on init
    public static var almostRequired: UILayoutPriority {
        UILayoutPriority(UILayoutPriority.required.rawValue - 1)
    }
}
