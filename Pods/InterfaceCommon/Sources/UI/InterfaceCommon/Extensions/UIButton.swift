import UIKit

extension UIButton {
    /// Sets the `contentEdgeInsets` and `titleEdgeInsets` accordingly for the given `contentPadding` and `imageTitlePadding`
    func setPadding(contentPadding: UIEdgeInsets, imageTitlePadding: CGFloat) {
        self.contentEdgeInsets = UIEdgeInsets(top: contentPadding.top,
                                              left: contentPadding.left,
                                              bottom: contentPadding.bottom,
                                              right: contentPadding.right + imageTitlePadding)
        self.titleEdgeInsets = UIEdgeInsets(top: 0,
                                            left: imageTitlePadding,
                                            bottom: 0,
                                            right: -imageTitlePadding)
    }
}
