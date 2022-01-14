import AVFoundation

/// Configures the output behavior of the `IOController`.
///
public struct OutputConfiguration {
    
    /// Indicates the appropriate behavior for the output.
    ///
    public enum Behavior: Equatable {
        
        /// All samples are written to a single file. This treats "stop" the same as "pause".
        ///
        /// In practice, this means that the `endOutput()` method of the `output` is only invoked at the very end of recording.
        /// This behavior would be expected in a streaming video scenario or one where recording can be paused and resumed on
        /// a single clip.
        ///
        case continuous
        
        /// Treats each group of samples as independent from those that came before.
        ///
        /// When sample recording is stopped and started again, the `endRecording()` and `startRecording()` methods on
        /// the `output` are called. This behavior would be expected in a scenario where multiple clips are being recorded.
        case discreet
    }
    
    public let output: SampleOutput
    
    public let outputBehavior: Behavior
}
