import Foundation

/// The `RollingAverage` type provides an efficient means of calculating the average
/// of recent values in a numeric data stream.
///
/// - Complexity: This type achieves O(1) performance for adding new values and O(n) complexity
///               when calculating the average.
///
struct RollingAverage<T:Numeric> {
    
    /// The number of entries kept in the buffer.
    ///
    /// When a new value is added, the oldest buffer value is overwritten.
    ///
    private(set) public var bufferDepth: Int
    
    /// Storage for buffer.
    private var buffer: [T]
    
    /// Indicates the oldest value in the buffer, which will be overwritten next.
    private var bufferIndex: Int = 0
    
    /// Used to calculate the average correctly when the buffer isn't full yet.
    private var bufferIsFull = false
    
    /// Create a new `RollingAverage`.
    ///
    /// - Parameters:
    ///     - bufferDepth: The number of entries kept in the buffer. Higher values result in more data smoothing.
    ///     - initialValue: The initial value to which all buffer entries are set. Default is `0`.
    ///
    init(bufferDepth: Int = 10, initialValue: T? = nil) {
        self.bufferDepth = bufferDepth
        if let value = initialValue {
            buffer = Array<T>(repeating: value, count: bufferDepth)
            bufferIsFull = true
        } else {
            buffer = []
            buffer.reserveCapacity(bufferDepth)
        }
    }
    
    /// Adds a new value to the `RollingAverage` (by overwriting the oldest value) and returns the updated average.
    ///
    /// - Parameter value: The value to add to the buffer.
    ///
    mutating func add(_ value: T) {
        if bufferIsFull {
            buffer[bufferIndex] = value
        } else {
            buffer.append(value)
        }
        bufferIndex = (bufferIndex + 1) % bufferDepth
        if bufferIndex == 0 { bufferIsFull = true }
    }
    
    /// The sum of all values in the buffer.
    var sum: T { buffer.reduce(0, +) }
}

// MARK: - Average

// We need to implement average as two separate, constrained extensions because the division operation
// (which is central to calculating an average) is defined in 2 sibling protocols: BinaryInteger and FloatingPoint.

extension RollingAverage where T: BinaryInteger {
    /// The average of all values in the buffer.
    ///
    /// If the buffer isn't full yet, then the average of the available values is calculated. If the buffer
    /// is empty then 0 is returned.
    ///
    var average: T {
        guard !buffer.isEmpty else { return T.zero }
        guard bufferIsFull else { return sum / T(bufferIndex) }
        return sum / T(bufferDepth)
    }
}

extension RollingAverage where T: FloatingPoint {
    /// The average of all values in the buffer.
    ///
    /// If the buffer isn't full yet, then the average of the available values is calculated. If the buffer
    /// is empty then 0 is returned.
    ///
    var average: T {
        guard !buffer.isEmpty else { return T.zero }
        guard bufferIsFull else { return sum / T(bufferIndex) }
        return sum / T(bufferDepth)
    }
}
