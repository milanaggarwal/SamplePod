import UIKit
import InterfaceCommon

public struct Pen {
    
    /// The brush color of the pen.
    var color: UIColor
    
    /// The previous color of the pen.
    var previousColor: UIColor = ColorPickerPreset.red.color
    
    /// The brush size of the pen.
    var size: CGFloat
    
    /// The pin brush size of the pen.
    var minSize: CGFloat
    
    /// The max brush size of the pen.
    var maxSize: CGFloat
    
    /// The scale factor for adjusting pen size.
    let scaleFactor: CGFloat
    
    /// The rainbow effect.
    var rainbow: Rainbow
    
    public struct Rainbow {
        /// If the rainbow is active
        var active: Bool = true
        
        /// The active hue of the rainbow
        var hue: CGFloat = 0.0
    }
    
    public init(color: UIColor = ColorPickerPreset.red.color, size: CGFloat = 10) {
        self.color = color
        self.size = size
        self.minSize = 5
        self.maxSize = 100
        self.scaleFactor = 1.08
        self.rainbow = Rainbow()
    }
}
