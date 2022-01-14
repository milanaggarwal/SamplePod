import UIKit

public class RoundedButton: IconButton {
    static let size = CGSize(width: 40, height: 40)

    private var addedRightTouchArea: CGFloat = 0
    private var addedLeftTouchArea: CGFloat = 0

    public override func point(inside point: CGPoint, with _: UIEvent?) -> Bool {
        let adjustedBounds = CGRect(
            x: bounds.origin.x - addedLeftTouchArea,
            y: bounds.origin.y,
            width: bounds.width + addedLeftTouchArea + addedRightTouchArea,
            height: bounds.height
        )
        return adjustedBounds.contains(point)
    }
}
