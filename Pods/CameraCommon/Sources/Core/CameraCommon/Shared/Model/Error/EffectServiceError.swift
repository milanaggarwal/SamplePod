import Foundation

public enum EffectServiceError: Error {
    case sourceNotFound
    case sourceNotRegistered
    case itemSelectionFailed
    case unknownError
}
