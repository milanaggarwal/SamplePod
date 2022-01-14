/// Errors thrown by Media Member operations.
/// 
public enum MediaMemberError: Error {
    
    /// The provided time was invalid.
    ///
    /// This can happen when you try to set a negative start time, set the start time after the end time, etc.
    ///
    case invalidTime
    
    /// The specified media type was not contained in the clip.
    /// 
    case mediaTypeNotFound
}
