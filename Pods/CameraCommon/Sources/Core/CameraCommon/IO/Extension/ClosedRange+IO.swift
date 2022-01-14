public extension ClosedRange {
    
    /// Constrain a value to fall within the range.
    ///
    /// - Parameter value: The number to clamp to the range's bounds.
    /// - Returns: The clamped value falling in the range `lowerBound <= value <= upperBound`
    ///
    func clamping(_ value: Bound) -> Bound {
        return Swift.max(lowerBound, Swift.min(upperBound, value))
    }
}
