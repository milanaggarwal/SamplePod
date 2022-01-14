import Foundation
import Combine
import CoreMedia
import AVFoundation

final public class DefaultTrackController: TrackController {
    
    private var _mediaTracks: [MediaTrack] {
        get {
            _mediaTrackSubject.value
        }
        set {
            _mediaTrackSubject.value = newValue
        }
    }
    
    private var _effectTracks: [EffectTrack] {
        get {
            _effectTrackSubject.value
        }
        set {
            _effectTrackSubject.value = newValue
        }
    }
    
    public var mediaTracks: AnyPublisher<[MediaTrack], Never> {
        _mediaTrackSubject.eraseToAnyPublisher()
    }
    
    public var effectTracks: AnyPublisher<[EffectTrack], Never> {
        _effectTrackSubject.eraseToAnyPublisher()
    }
    
    private let _mediaTrackSubject = CurrentValueSubject<[MediaTrack], Never>([])
    
    private let _effectTrackSubject = CurrentValueSubject<[EffectTrack], Never>([])
    
    public var currentTracks: [Track] { _mediaTracks + _effectTracks }
    
    public var allTracks: AnyPublisher<[Track], Never> {
        _mediaTrackSubject
            .combineLatest(_effectTrackSubject)
            .map { $0 + $1 }
            .eraseToAnyPublisher()
    }
    
    public var duration: AnyPublisher<CMTime, Never> {
        allTracks
            .map { tracks in
                tracks
                    .compactMap { $0.timeRange.end }
                    .filter { $0 != .positiveInfinity }
                    .max() ?? .zero
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    public var currentDuration: CMTime {
        currentTracks
            .map(\.timeRange.end)
            .filter { $0 != .positiveInfinity }
            .max() ?? .zero
    }
    
    public init() {
    }
        
    public func addTrack(_ track: Track) {
        switch track.type {
        case .media:
            guard let mTrack = track as? MediaTrack else { return }
            _mediaTracks.append(mTrack)
        case .effect:
            guard let eTrack = track as? EffectTrack else { return }
            _effectTracks.append(eTrack)
        }
    }
    
    public func removeTrack(_ track: Track) {
        switch track.type {
        case .media:
            _mediaTracks = _mediaTracks.filter { $0.id != track.id }
        case .effect:
            _effectTracks = _effectTracks.filter { $0.id != track.id }
        }
    }
    
    public func tracks(of type: Track.TrackType) -> [Track] {
        switch type {
        case .media:
            return _mediaTracks
        case .effect:
            return _effectTracks
        }
    }
    
    public func mediaTracks(of type: MediaTrack.MediaType) -> [MediaTrack] {
        _mediaTracks.filter { $0.mediaType == type }
    }
    
    public func getTrackMix() throws -> TrackMix {
        
        let composition = AVMutableComposition()
        let audioMix = AVMutableAudioMix()
        do {
            try _mediaTracks.forEach { try $0.addTrack(to: composition, audioMix: audioMix) }
        } catch {
            throw TrackControllerError.failedToCreateMix
        }
        
        return TrackMix(asset: composition, audioMix: audioMix, videoComposition: nil)
    }
}
