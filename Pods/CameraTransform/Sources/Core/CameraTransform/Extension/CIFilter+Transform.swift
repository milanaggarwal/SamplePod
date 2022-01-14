import CoreImage

public extension CIFilter {
    /// Indicates whether or not the filter accepts an input image.
    ///
    /// Some filters, particularly those in the `Generator` family produce output without any input image.
    ///
    var hasInputImage: Bool {
        self.inputKeys.contains(kCIInputImageKey)
    }
}
