import UIKit

extension UIDevice {
    public var hasHomeIndicatorBar: Bool {
        homeIndicatorBarInset > 0
    }

    public var homeIndicatorBarInset: CGFloat {
        UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets.bottom ?? 0
    }

    public var hasNotch: Bool {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return false }
        return notchHeight > 0
    }

    public var notchHeight: CGFloat {
        guard hasHomeIndicatorBar else { return 0 }
        let topInset: CGFloat
        switch UIApplication.shared.orientation {
        case .landscapeLeft:
            topInset = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets.right ?? 0
        case .landscapeRight:
            topInset = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets.left ?? 0
        case .portrait:
            topInset = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets.top ?? 0
        default: return 0
        }
        return topInset - 14
    }
}
