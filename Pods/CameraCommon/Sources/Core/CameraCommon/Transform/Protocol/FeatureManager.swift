import Foundation
import Combine

/// The FeatureManager gathers features asynchronously from different sources and makes them available
/// to layers during the update phase.
///
public protocol FeatureManager: AnyObject {

    /// The feature dictionary type.
    ///
    typealias FeatureDictionary = [String : Any]

    /// The current set of features.
    ///
    var currentFeatures: FeatureDictionary { get }

    /// The Combine interface for features.
    ///
    var features: AnyPublisher<FeatureDictionary, Never> { get }

    /// Adds or updates a feature.
    ///
    /// - Parameter feature: The feature object to be added or updated in the feature dictionary.
    /// - Parameter key: The key to add the feature at.
    ///
    func addOrUpdate(feature: Any, forKey key: String)
    
    /// Removes the feature for the specified key.
    ///
    /// If there is a Combine subscription for the specified key, then it is cancelled as well.
    ///
    /// - Parameter key: The key to remove the feature at.
    ///
    func removeFeature(forKey key: String)
}
