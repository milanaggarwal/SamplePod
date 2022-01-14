import UIKit

/// Builder object for Icon button
public class IconButtonConfiguration: Equatable {
    
    /// The image to display inside the button
    public var image: UIImage?
    
    /// The image to display inside the button when it is selected
    public var selectedImage: UIImage?
    
    /// The background color of the button
    public var backgroundColor: UIColor = .clear
    
    /// The background color of the button when it is selected
    public var selectedBackgroundColor: UIColor = .clear
    
    /// The image to display inside the button in dark mode
    public var darkModeImage: UIImage?
    
    /// The image to display inside the button when it is selected in dark mode
    public var darkModeSelectedImage: UIImage?
    
    /// The color to use for the button's label in dark mode
    public var darkModeTextColor: UIColor?
    
    /// The background color of the button in dark mode
    public var darkModeBackgroundColor: UIColor?
    
    /// The background color of the button when it is selected in dark mode
    public var darkModeSelectedBackgroundColor: UIColor?
    
    /// The height to constraint the button to
    public var height: CGFloat = 0
    
    /// The width to constraint the button to
    public var width: CGFloat = 0
    
    /// The corner radius for the button
    public var cornerRadius: CGFloat = 0
    
    /// The image's edge insets
    public var imageEdgeInsets: UIEdgeInsets = .zero
    
    public var clipToBounds: Bool = false
    
    public var borderColor: UIColor = .clear
    
    public var borderWidth: CGFloat = 0
    
    /*
     Returns the localized label that represents the element.
     If the element does not display text (an icon for example), this method
     should return text that best labels the element. For example: "Play" could be used for
     a button that is used to play music. "Play button" should not be used, since there is a trait
     that identifies the control is a button.
     default == nil
     */
    public var accessibilityLabel: String?
    
    public init() {
        
    }
    
    public static func == (lhs: IconButtonConfiguration, rhs: IconButtonConfiguration) -> Bool {
        if let image = lhs.image?.pngData(),
           let configurationImage = rhs.image?.pngData()
        {
            // Pretty raw?
            if image.count != configurationImage.count {
                return false
            }
        }
        return lhs.height == rhs.height &&
        lhs.width == rhs.width &&
        lhs.cornerRadius == rhs.cornerRadius &&
        lhs.imageEdgeInsets == rhs.imageEdgeInsets &&
        lhs.backgroundColor == rhs.backgroundColor &&
        lhs.selectedBackgroundColor == rhs.selectedBackgroundColor
    }
}
