/// Errors that can be thrown by a `MediaAsset`.
///
public enum MediaAssetError: Error {
    
    /// The asset does not exist locally, yet.
    case assetNotReady
    
    /// The local URL supplied to the media asset is invalid.
    case invalidUrl
}
