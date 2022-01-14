import UIKit

extension UIAccessibility {
    /// Post accessibility notification for string object
    public static func accessibilityAnnouncement(string: String?, notification: UIAccessibility.Notification = .screenChanged) {
        UIAccessibility.post(notification: notification, argument: string)
    }
}
