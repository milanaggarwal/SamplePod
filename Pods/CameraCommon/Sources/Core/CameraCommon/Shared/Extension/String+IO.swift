import Foundation

public extension String {
    /// Convert a 4-character String into a `FourCharCode`.
    var fourCharCode: FourCharCode? {
        guard self.utf16.count == 4 else {
            assertionFailure("String must contain exactly 4 UTF-16 code points.")
            return nil
        }
        return self.utf16.reduce(FourCharCode(0)) { ($0 << 8) + FourCharCode($1) }
    }

    /// Initializes a String from the given number
    /// - Parameters:
    ///   - double: The number to create a string for
    ///   - decimalPlaces: The number of decimal places to format the string to
    init(double: Double, numberOfDecimalPlaces decimalPlaces: Int) {
        self.init(String(format: "%.\(decimalPlaces)f", double))
    }
}

