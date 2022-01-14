public enum DeviceControlServiceError: Error {
    case noMediaSourcesSpecified
    case configurationFailedForCameras
    case configurationFailedForMicrophones
    case unableToActivateMediaSources
    case unableToActivateCamera
    case unableToActivateMicrophone
}
