/// Errors that can be produced by a `SampleOutput`.
///
public enum SampleOutputError: Error {
    case failedToOutputSample
    case cannotStartSampleOutput
    case cannotEndSampleOutput
}
