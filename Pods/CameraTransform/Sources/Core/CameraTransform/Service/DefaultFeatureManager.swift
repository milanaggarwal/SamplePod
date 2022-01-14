import Foundation
import CameraCommon
import Combine

/// This is the default implementation of the `FeatureManager` protocol.
///
public final class DefaultFeatureManager: FeatureManager {
    
    /// While there may be some rationalle for having multiple feature managers that we haven't thought of,
    /// for now a singleton is the most convenient.
    ///
    public static let shared: DefaultFeatureManager = DefaultFeatureManager()
    
    /// Keep track of the features.
    private(set) public var currentFeatures: FeatureDictionary = [:] {
        didSet {
            featuresPublisher.send(currentFeatures)
        }
    }
    
    public var features: AnyPublisher<FeatureDictionary, Never> {
        return featuresPublisher.eraseToAnyPublisher()
    }
    
    /// Using a `CurrentValueSubject` so that subscribers immediately recieve the latest features.
    private var featuresPublisher = CurrentValueSubject<FeatureDictionary, Never>([:])
    
    // Just protocol stuff.
    public func addOrUpdate(feature: Any, forKey key: String) {
        currentFeatures[key] = feature
    }
    
    public func removeFeature(forKey key: String) {
        currentFeatures[key] = nil
    }
    
    /// Create an instance of `DefaultFeatureManager`.
    public init() {
        // Nothing, yet.
    }
}
