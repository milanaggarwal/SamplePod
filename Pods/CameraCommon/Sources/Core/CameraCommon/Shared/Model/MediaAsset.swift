import AVFoundation
import Combine

/// A single piece of media: video or audio.
///
/// Since media may need to be retrieved from remote sources, the object has a status
/// that indicates whether or not the media is ready to use. If the media is not ready when
/// a caller requests it, the caller may add an observer (via callback or Combine) in order
/// to be notified when the asset is available.
///
public class MediaAsset: Equatable, Hashable, Codable {
        
    /// The current status of the media object.
    ///
    /// Normally, the `status` of a `MediaAsset` will move uni-directionally from `.unavailable`
    /// to `.downloading` to `.ready`. However, this is not gauranteed, so objects interested in
    /// the status of a `MediaAsset` should be preparred to handle retrograde changes.
    ///
    public enum Status: String, Codable {
        
        /// The item is not available locally and has not yet begun loading (could be enqueued).
        case unavailable
        
        /// The asset is currently being downloaded.
        case downloading
        
        /// The asset is currently being written to by a recording session.
        case writing
        
        /// The asset is downloaded and available for use.
        case ready
    }
    
    /// A unique identifier for the object.
    public let id: UUID
    
    /// The current status of the object.
    public var currentStatus: Status { _status.value }
    
    /// The type of media asset this is.
    public var type: MediaType
    
    /// The total duration of this media.
    public var duration: CMTime = .indefinite
    
    /// If the item exists locally, this property will point to it. Otherwise, it will be `nil`.
    public var localUrl: URL? = nil
    
    /// Marks the asset as soft-deleted.
    ///
    /// The asset will be deleted on cleanup, but can be un-deleted prior to that time.
    ///
    public var isDeleted: Bool = false
    
    public var status: AnyPublisher<Status, Never> {
        _status.eraseToAnyPublisher()
    }
    
    /// The publisher backing the status.
    private var _status: CurrentValueSubject<Status, Never>
    
    /// Quickly indicates whether the object is in a `.ready` status.
    public var isReady: Bool {
        guard _status.value == .ready else { return false }
        return true
    }
    
    private var asset: AVURLAsset?
    
    /// Decodable
    /// 
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.type = try container.decode(MediaType.self, forKey: .type)
        self._status = CurrentValueSubject(try container.decode(Status.self, forKey: .status))
        self.localUrl = try container.decode(URL.self, forKey: .localUrl)
    }
            
    /// Create a new `MediaAsset`.
    ///
    /// - Parameters:
    ///     - id: The unique identifier of the `MediaAsset`.
    ///     - type: The media type the asset contains.
    ///     - localUrl: The local URL of the asset, if it exists.
    ///
    /// - Throws: `MediaAssetError.invalidUrl` if the `localUrl` parameter is specified with an invalid local URL.
    ///
    public init(id: UUID = UUID(), type: MediaType, status: Status = .unavailable, localUrl: URL? = nil) throws {
        self.id = id
        self.type = type
        if let url = localUrl {
            guard url.isFileURL else { throw MediaAssetError.invalidUrl }
            self.localUrl = url
        }
        self._status = CurrentValueSubject(status)
    }
    
    /// Change the status of the `MediaAsset`.
    ///
    /// - Parameter status: The new status to assign to the asset.
    ///
    public func set(status: Status) {
        _status.send(status)
    }
    
    /// Attempt to create an `AVAsset` from the local media file.
    ///
    /// - Throws: `MediaAssetError.assetNotReady` if the asset is not in a `.ready` state with a local URL.
    ///
    public func getAsset() throws -> AVAsset {
        if let asset = asset {
            return asset
        }
        guard
            let url = localUrl,
            try url.checkResourceIsReachable(),
            currentStatus == .ready
        else { throw MediaAssetError.assetNotReady }
        let urlAsset = AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey : true])
        self.asset = urlAsset
        return urlAsset
    }
}

// MARK: - Equatable

public extension MediaAsset {
    static func == (lhs: MediaAsset, rhs: MediaAsset) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable

public extension MediaAsset {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Codable

public extension MediaAsset {
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case status
        case localUrl
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(_status.value, forKey: .status)
        try container.encode(localUrl, forKey: .localUrl)
    }
}
