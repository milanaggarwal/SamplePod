import Foundation
import CoreMedia
import AVFoundation
import Combine

/// A `VideoProject` is a complete description of the state of a video being prepared for upload.
///
public final class VideoProject {
    
    /// The unique identifier for this project.
    let id: UUID
    
    public let recordingLimit: TimeInterval
    
    /// Provides a list of current media members part of the video project
    public var memberAssets : [MediaAsset] {
        Array(assetMemberMap.keys)
    }
    
    /// Total duration of video in CMTime
    public var videoDuration: CMTime {
        members.reduce(CMTime.zero) { result, member in CMTimeAdd(result, member.duration) }
    }
    
    /// Returns array of timestamps representing first frame for each member present
    public var firstFrameTimeStamps: [CMTime] {
        var firstFrameTimeStamps = [CMTime]()
        var startTime: CMTime = .zero
        for member in members {
            firstFrameTimeStamps.append(startTime)
            startTime = CMTimeAdd(startTime, member.duration)
        }
        return firstFrameTimeStamps
    }
    
    private lazy var deleteMediaAssetSubject = PassthroughSubject<MediaAsset, Never>()
    public var deleteMediaAssetPublisher: AnyPublisher<MediaAsset, Never> {
        deleteMediaAssetSubject.eraseToAnyPublisher()
    }
    
    /// The media clips created from the assets.
    private(set) public var members: [MediaMember] = []
    
    /// Reference map for media asset and the members referencing that media asset
    /// To be used in case of deleting the media asset when no member is left which is accessing that asset
    private var assetMemberMap: [MediaAsset: [MediaMember]] = [:]
    
    ///Contains all the tracks in current recording session
    public var trackController = DefaultTrackController()
    
    private var videoTrack: MediaTrack
    
    /// Initiate a video project
    /// - Parameter id: Optional uid for identifying video proejct
    /// - Parameter recordingLimit: max time limit allowed for the final video in the project
    ///
    public init(id: UUID = UUID(), recordingLimit: TimeInterval) {
        self.id = id
        self.videoTrack = MediaTrack(id: id, mediaType: .video, behavior: .gapless)
        trackController.addTrack(videoTrack)
        self.recordingLimit = recordingLimit
    }
    
    /// Add member to video project
    public func add(member: MediaMember) {
        self.members.append(member)
        if var mappedMembers = assetMemberMap[member.mediaAsset] {
            mappedMembers.append(member)
            assetMemberMap[member.mediaAsset] = mappedMembers
        } else {
            assetMemberMap[member.mediaAsset] = [member]
        }
        do{
            if member.mediaType == .video{
                try videoTrack.addAtClosestValidTime(member)
            }
        }
        catch {
#warning("Handle warning properly")
        }
    }
    
    /// Insert member to video project at index
    public func insert(member: MediaMember, at index: Int) {
        self.members.insert(member, at: index)
        if var mappedMembers = assetMemberMap[member.mediaAsset] {
            mappedMembers.append(member)
            assetMemberMap[member.mediaAsset] = mappedMembers
        } else {
            assetMemberMap[member.mediaAsset] = [member]
        }
        if member.mediaType == .video{
            try videoTrack.insertMember(member: member, at: index)
        }
    }
    
    /// Remove the media member from the project
    public func remove(member memberToBeRemoved: MediaMember) {
        if var mappedMembers = assetMemberMap[memberToBeRemoved.mediaAsset] {
            mappedMembers.removeAll { member in
                memberToBeRemoved.id == member.id
            }
            if mappedMembers.count == 0 {
                assetMemberMap.removeValue(forKey: memberToBeRemoved.mediaAsset)
                deleteMediaAssetSubject.send(memberToBeRemoved.mediaAsset)
            } else {
                assetMemberMap[memberToBeRemoved.mediaAsset] = mappedMembers
            }
        } else {
            return
        }
        self.members.removeAll { member in
            memberToBeRemoved.id == member.id
        }
        if memberToBeRemoved.mediaType == .video{
            videoTrack.removeMember(byId: memberToBeRemoved.id)
        }
    }
    
    /// Remove all media members from project
    public func removeAll() {
        self.members = []
        for mediaAsset in assetMemberMap.keys {
            deleteMediaAssetSubject.send(mediaAsset)
        }
        assetMemberMap = [:]
        videoTrack.removeAllMembers()
    }
    
    /// Return final asset which will be use to save video.
    public func getVideo() -> AVAsset? {
        var asset: AVAsset?
        do{
            asset = try trackController.getTrackMix().asset
        }
        catch{
#warning("Handle warning properly")
        }
        return asset
    }
  
    /// Returns the member for the given timestamp
    public func memberAt(time: TimeInterval) -> MediaMember? {
        guard time > 0 && time < videoDuration.seconds else { return nil }
        var memberIndex = 0
        while memberIndex < members.count && time > firstFrameTimeStamps[memberIndex].seconds {
            memberIndex = memberIndex + 1
        }
        return members[memberIndex - 1]
    }
    
    /// Move member from index a to b
    ///
    public func moveMember(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let member = members.remove(at: sourceIndexPath.row)
        members.insert(member, at: destinationIndexPath.row)
        if member.mediaType == .video{
            videoTrack.moveMember(at: sourceIndexPath, to: destinationIndexPath)
        }
    }
    
    /// Call this function to update start and endtime for media member during trim/split operation
    /// - Parameter member: member for which start time or end time needs to be updated
    /// - Parameter startOffset: The offset by which startTime needs to be increased from 0
    /// - Parameter endOffset: The offset by which endTime needs to be decreased from the end
    ///
    public func update(member: MediaMember, startOffset: CMTime? = nil, endOffset: CMTime? = nil) {
        if let startTime = startOffset {
            try? member.set(startTime: startTime)
        }
        if let endOffset = endOffset {
            let endTime = CMTimeSubtract(member.totalDuration, endOffset)
            try? member.set(endTime: endTime)
        }
    }
}

extension VideoProject {
    public func formattedStartTime(forMember member: MediaMember) -> String? {
        return String(double: member.startTime?.seconds ?? 0, numberOfDecimalPlaces: 1)
    }
    
    public func formattedEndTime(forMember member: MediaMember) -> String? {
        return String(double: member.endTime?.seconds ?? 0, numberOfDecimalPlaces: 1)
    }
}
