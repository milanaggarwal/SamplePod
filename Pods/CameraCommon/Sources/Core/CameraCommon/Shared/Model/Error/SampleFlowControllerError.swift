import Foundation

public enum SampleFlowControllerError: Error {
    case cannotChangeConfigurationWhileActive
    case failedToProcessSample
    case failedToOutputSample
}
