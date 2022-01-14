import Combine
import Foundation

/// Defines a type that can record a video
public protocol VideoRecorder: SampleOutput {
    /// Whether or not the recorder is currently recording
    var isRecording: Bool { get }
    var isRecordingPublisher: AnyPublisher<Bool, Never> { get }
    /// The amount of time left that the user can record for, nil if there is no limit
    var recordingTimeRemaining: TimeInterval? { get }
    var recordingTimeRemainingPublisher: AnyPublisher<TimeInterval?, Never> { get }
    /// The media assets that were recorded
    var recordedAssets: [MediaAsset] { get }
    var recordedAssetsPublisher: AnyPublisher<[MediaAsset], Never> { get }
    /// The maximum length of video that can be recorded, nil if no limit
    var recordingLimit: Double? { get }
    /// Starts the recording process.
    func startRecording()
    /// Stops the recording process.
    func stopRecording()
    /// Clears all recordings
    func clearRecordings()
}
