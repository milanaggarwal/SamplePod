import Foundation

/// Indicate imported video uploading status
public enum ExportProgressEvent{
    
    /// Status set when Import started
    case started
    
    /// Update progress view with progress percentage
    case updated(completionRatio: Float)
    
    /// Indicate completed status of import video
    case completed
    
    /// Indicate import has been cancelled
    case cancelled
    
    /// Indicate filure of import video with string
    case failure(errorString: String)
}
