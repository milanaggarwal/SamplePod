/// Errors thrown by the `RecordingController`.
///
public enum RecordingControllerError: Error {
    case assetNotFound
    case assetCannotBeWrittenTo
    case assetCannotBeDeleted
    case deviceStorageFull
    case cannotCreateImageWithoutData
}
