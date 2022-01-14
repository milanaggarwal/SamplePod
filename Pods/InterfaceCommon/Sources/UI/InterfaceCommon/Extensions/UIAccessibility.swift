import Foundation
import UIKit

public extension UIAccessibility {
    static func focusAccesibilityElement(element: Any?, notification: UIAccessibility.Notification = .screenChanged) {
        UIAccessibility.post(notification: notification, argument: element)
    }

    static func accesibilityAnnouncement(string: String?, notification: UIAccessibility.Notification = .screenChanged) {
        UIAccessibility.post(notification: notification, argument: string)
    }
}
