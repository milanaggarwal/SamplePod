import Foundation
import CoreMedia

/// This class provides shared functionality to `MediaMember` and `EffectMember`.
///
/// This class should not be instantiated directly, as it contributes nothing to a project.
/// Instead, subclass it to provide specific functionality.
///
open class Member: Equatable, Comparable, CustomStringConvertible {
    
    /// The unique identifier of the `Member`.
    ///
    public let id: UUID
    
    /// Indicates what type of track this `Member` is designed to work with.
    public let type: Track.TrackType

    /// The starting time of the `Member`.
    ///
    /// If the value of this is `nil`, then the `Member` is assumed to start at time `0.0`.
    ///
    open var startTime: CMTime?
    
    /// The ending time of the `Member`.
    ///
    /// If the value of this is `nil`, then the `Member` is assumed to last until `infinity`.
    /// It is assumed that the `endTime` is *after* the end of the member, thus testing
    /// inclusion of a time that is exactly `endTime` will return false. This is so adjacent
    /// members can have the same end and start times and not "overlap".
    ///
    open var endTime: CMTime?
    
    /// The effective range of the `Member`, based on its start and end times.
    open var timeRange: CMTimeRange {
        let start = startTime ?? .zero
        let end = endTime ?? .positiveInfinity
        return CMTimeRange(start: start, end: end)
    }
    
    /// Returns whether or not this Member has a finite (closed range) duration.
    ///
    /// Any member lacking either a start or end time (or both) is considered unbounded.
    ///
    public var isBounded: Bool { startTime != nil && endTime != nil }
    
    /// The duration of the member.
    ///
    public var duration: CMTime {
        let start = startTime ?? .zero
        let end = endTime ?? .positiveInfinity
        return end - start
    }
    
    /// Makes identifying members while debugging easier.
    public var debugName: String? = nil
    
    ///
    public init(id: UUID = UUID(), type: Track.TrackType, startTime: CMTime?, endTime: CMTime?) {
        self.id = id
        self.type = type
        self.startTime = startTime
        self.endTime = endTime
    }
    
    /// Change the `startTime` of the `MediaMember`.
    ///
    /// - Parameter startTime: The new start time for the `MediaMember`.
    ///
    public func set(startTime: CMTime?) {
        self.startTime = startTime
    }
    
    /// Change the `endTime` of the `MediaMember`.
    ///
    /// - Parameter endTime: The new end time for the `MediaMember`.
    ///
    public func set(endTime: CMTime?) {
        self.endTime = endTime
    }
    
    /// Time-shift the the `Member` by the specified amount.
    ///
    /// This will have no effect on an unbounded start/end value for the `Member`.
    ///
    /// - Parameter time: The amount of time (in seconds) to time-shift the `Member`. The value can be positive or negative,
    ///                   which will move the `Member` later or earlier in time, respectively.
    ///
    open func offset(by time: Double) {
        guard let end = endTime else {
            return
        }
        if let start = startTime {
            let offset = CMTime(seconds: time, preferredTimescale: end.timescale)
            startTime = start + offset
        }
        let offset = CMTime(seconds: time, preferredTimescale: end.timescale)
        endTime = end + offset
    }
    
    /// Indicates whether or not the Member contains the specified time.
    open func contains(time: CMTime) -> Bool {
        timeRange.containsTime(time)
    }

    // MARK: - Equatable
    
    public static func == (lhs: Member, rhs: Member) -> Bool { lhs.id == rhs.id }
    
    // MARK: - Comparable
    
    public static func < (lhs: Member, rhs: Member) -> Bool { (lhs.startTime ?? .zero) < (rhs.startTime ?? .zero) }
    
    // MARK: - CustomStringConvertible
    
    public var description: String {
        "Member(id: \(debugName ?? id.uuidString), s: \(startTime?.seconds ?? 0.0), e: \(endTime?.seconds ?? Double.infinity))"
    }
}
