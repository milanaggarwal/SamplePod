import Foundation
import Combine
import CoreMedia

open class Track: Equatable, CustomStringConvertible {
    
    /// Indicates the behavior of the track.
    public enum TrackType: Equatable {
        
        /// The track provides media samples to the project.
        case media
        
        /// The track modifies samples.
        case effect
    }
    
    /// Controls how other Members behave when a member is added or removed.
    public enum PlacementBehavior: Equatable {
        
        /// The track contains a single (usually unbounded) member.
        case single
        
        /// Members may not overlap and may not have gaps between them.
        case gapless
    }
    
    /// The unique identifier of the `Track`.
    public let id: UUID
    
    public let type: TrackType
    
    /// How the `Track` manages the relative positioning of it's members.
    public let behavior: PlacementBehavior

    /// Publishes a list of the members that a track contains.
    ///
    public var members: AnyPublisher<[Member], Never> {
        _members.eraseToAnyPublisher()
    }
    
    /// The subject backing `members`.
    private let _members = CurrentValueSubject<[Member], Never>([])
    
    /// A snapshot members currently present in the Track.
    public var currentMembers: [Member] {
        _members.value
    }

    /// Used for identifying the track while debugging.
    public var debugName: String?
    
    /// Get the active time range of the track.
    public var timeRange: CMTimeRange {
        currentMembers.reduce(CMTimeRange.zero) { $0.union($1.timeRange) }
    }
    
    /// Get the total duration of all members of track
    public var totalDuration: CMTime {
        var totalDuration = CMTime.zero
        currentMembers.forEach { 
            totalDuration = totalDuration + $0.duration
        }
        return totalDuration
    }
    
    /// Create a new `Track`.
    ///
    /// This class should not be instantiated directly. Instead, subclass it to provide the desired behavior.
    ///
    /// - Parameters:
    ///     - id: The unique identifier of this `Track`.
    ///     - behavior: The behavior when placing members into this `Track`.
    ///
    public init(id: UUID, type: TrackType, behavior: PlacementBehavior) {
        self.id = id
        self.type = type
        self.behavior = behavior
    }

    /// Add a Member at the closest valid start time to the Member's start.
    ///
    public func addAtClosestValidTime(_ member: Member) throws {
        guard member.type == type else { throw TrackError.incorrectMemberType }
        var members = currentMembers
        if behavior == .single {
            members = [member]
        } else {
            members.append(member)
        }
        updateMembers(members)
    }
    
    /// Add a Member to the end of the Track.
    ///
    public func append(_ member: Member) throws {
        guard member.type == type else { throw TrackError.incorrectMemberType }
        if behavior == .gapless {
            guard
                member.isBounded,
                let start = member.startTime
            else { throw TrackError.cannotAddUnboundedMember }
            let end = timeRange.end
            let offset = (end - start).seconds
            member.offset(by: offset)
        }
        var members = currentMembers
        members.append(member)
        updateMembers(members)
    }
    
    /// Remove a Member from a Track.
    public func remove(_ member: Member) {
        
        // Double-check that the member is part of the array first.
        guard let memberIndex = currentMembers.firstIndex(of: member) else { return }
        var members = currentMembers
        members.remove(at: memberIndex)
        updateMembers(members)
    }
    
    /// Remove a Member by ID from a Track.
    public func removeMember(byId id: UUID) {
        // First, check that we have the member.
        guard let member = currentMembers.first(where: { $0.id == id }) else { return }
        remove(member)
    }
    
    /// Move a member in Track.
    public func moveMember(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var members = currentMembers
        let member = members.remove(at: sourceIndexPath.row)
        members.insert(member, at: destinationIndexPath.row)
        updateMembers(members)
    }
    
    /// Insert member at index in Track
    public func insertMember(member: Member,at index: Int) {
        var members = currentMembers
        members.insert(member, at: index)
        updateMembers(members)
    }
    
    /// Remove all members from
    public func removeAllMembers(){
        var members = currentMembers
        members = []
        updateMembers(members)
    }
    
    /// Sends updates to the members list.
    ///
    /// - Parameter members: The updated list of members.
    ///
    private func updateMembers(_ members: [Member]) {
        _members.send(members)
    }
    
    /// Finds a valid insertion point for the specified time.
    ///
    /// This method is designed to work with `.gapless` tracks, as a `.free` track can just place the `Member` anywhere.
    ///
    /// - Parameter time: The time to find an insertion point for.
    /// - Returns: The insertion time.
    ///
    public func insertionTime(for time: CMTime) -> CMTime {
        // We only invoke this behavior on gapless tracks. A free track can put a Member anywhere.
        guard behavior == .gapless else { return time }
        
        // If we have no existing members, just put it at the start.
        guard !currentMembers.isEmpty else { return .zero }
        
        // The time does not intersect with any of the members, put it at the end.
        guard
            let member = currentMembers.first(where: { $0.contains(time: time) }),
            let start = member.startTime,
            let end = member.endTime
        else {
            return timeRange.end
        }
        
        // Compute the distance to each end of the Member.
        let startDelta = abs((time - start).seconds)
        let endDelta = abs((time - end).seconds)
        
        // Return the bounding time with the shortest distance from the provided time.
        return startDelta < endDelta ? start : end
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: Track, rhs: Track) -> Bool { lhs.id == rhs.id }
    
    // MARK: - CustomStringConvertible
    
    public var description: String {
        var output = "Track(id: \(debugName ?? id.uuidString), type: \(type), behavior: \(behavior), members:"
        currentMembers.forEach({ output.append("\n\t\($0)") })
        output.append("\n)")
        return output
    }
}
