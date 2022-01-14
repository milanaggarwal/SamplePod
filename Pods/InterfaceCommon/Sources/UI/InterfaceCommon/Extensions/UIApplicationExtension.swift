import UIKit

extension UIApplication {
    /// Current interface orientation of the app
    public var orientation: UIInterfaceOrientation {
        windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation ?? .portrait
    }
}
