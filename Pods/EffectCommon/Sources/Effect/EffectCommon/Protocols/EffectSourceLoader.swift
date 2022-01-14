import Combine

/// This protocol enables a class to publish changes to effectSources of a particular EffectType
///
public protocol EffectSourceLoader {
    associatedtype EffectType
    var sourcesPublisher: AnyPublisher<[EffectType], Never> { get }
}

/// Enables the Source loader to implement search functionality
///
public protocol SearchableEffectSourceLoader: EffectSourceLoader {
    func search(withTerm searchTerm: String?)
}
