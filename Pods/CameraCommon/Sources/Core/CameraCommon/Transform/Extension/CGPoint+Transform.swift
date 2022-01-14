import UIKit

public extension CGPoint {
    
    /// Converts a CGPoint from UIKit's coordinate system to Core Image's system.
    ///
    /// - Parameter inRect: The rect in which the point resides. This is assumed to be in UIKit coordinates.
    /// - Parameter scale: The scale of points to pixels. Defaults to the screen resolution.
    /// - Returns: A CIVector representing the point in Core Image coordinates.
    ///
    func ciPoint(inRect rect: CGRect, scale: CGFloat = UIScreen.main.scale) -> CIVector {
        let x = self.x * scale
        let y = (rect.maxY - self.y) * scale
        return CIVector(x: x, y: y)
    }
}
