/// Errors that can be thrown by a `TransformController`.
///
public enum TransformControllerError: Error {
    /// The `TransformController` was unable to create ANY renderer.
    ///
    /// This is extremely unexpected, as a CPU-backed renderer should always be able to be created as a fallback.
    ///
    case unableToCreateRenderer
    
    /// Thrown if the controller is currently busy processing and cannot accept another sample.
    ///
    case controllerIsBusy
    
    case unableToRenderBuffer
}
