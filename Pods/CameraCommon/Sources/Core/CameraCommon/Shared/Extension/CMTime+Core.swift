import CoreMedia

public extension CMTime {
    
    /// Determines whether or not the `CMTime` has a valid, numeric value.
    ///
    var hasNumericValue: Bool {
        self != .invalid && self != .indefinite && self != .positiveInfinity && self != .negativeInfinity
    }
}
