import UIKit

public class Line {
    
    /// The unique ID of the Line.
    let id = UUID()
    
    /// The array of points on screen that this Line covers.
    var points: [Point] = []
    
    /// The time this Line was created.
    let createdAt = Date().timeIntervalSince1970

    init(points: [Point]) {
        self.points = points
    }
}
