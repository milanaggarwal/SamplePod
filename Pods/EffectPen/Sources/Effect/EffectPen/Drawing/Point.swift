import UIKit

class Point {
    
    /// The on-screen location that this point covers.
    var point: CGPoint
    
    /// The selected color for this Point.
    var color: CGColor
    
    /// The size of the brush
    var size: CGFloat

    init(point: CGPoint, color: CGColor, size: CGFloat) {
        self.point = point
        self.color = color
        self.size = size
    }
}
