import Foundation
import Combine

/// Default implementation for the `EffectService` protocol.
/// Manages addition/updation of effect source and uses a `TransformController` object to apply the selected effect by the user
///
public final class DefaultEffectService: EffectService {
    
    public var currentEffectSources: [EffectSource] { effectSourceSubject.value }
    
    public var effectSources: AnyPublisher<[EffectSource], Never> { effectSourceSubject.eraseToAnyPublisher() }
    
    /// The actual publisher for the `effectSources` property and the source of truth for the current `EffectSource` list.
    private let effectSourceSubject = CurrentValueSubject<[EffectSource], Never>([])
    
    /// The transform controller to add processors and layers to.
    private let transformController: TransformController
    
    /// Subscriptions for selections.
    private var subs = Set<AnyCancellable>()
        
    public init(transformController: TransformController, startingSources: [EffectSource] = []) {
        self.transformController = transformController
        effectSourceSubject.send(startingSources)
    }
    
    public func addOrUpdate(sources: [EffectSource]) {
        var finalSources = currentEffectSources
        for newSource in sources {
            if let oldIndex = finalSources.firstIndex(of: newSource) {
                finalSources.remove(at: oldIndex)
                finalSources.insert(newSource, at: oldIndex)
            } else {
                finalSources.append(newSource)
            }
        }
        effectSourceSubject.send(finalSources)
    }
    
    public func insert(source: EffectSource, atIndex index: Int) {
        var sources = currentEffectSources.filter { $0.id != source.id }
        if index == sources.count {
            sources.append(source)
        } else {
            let clampedIndex = max(0, min(index, sources.count - 1))
            sources.insert(source, at: clampedIndex)
        }
        effectSourceSubject.send(sources)
    }
    
    public func remove(source: EffectSource) throws {
        guard currentEffectSources.contains(source) else {
            throw EffectServiceError.sourceNotFound
        }
        let updatedSources = currentEffectSources.filter { $0 != source }
        effectSourceSubject.send(updatedSources)
    }
    
    public func remove(byId id: UUID) throws {
        let allIds = currentEffectSources.map(\.id)
        guard allIds.contains(id) else {
            throw EffectServiceError.sourceNotFound
        }
        let updatedSources = currentEffectSources.filter { $0.id != id }
        effectSourceSubject.send(updatedSources)
    }
    
    public func removeAll() {
        effectSourceSubject.send([])
    }
    
    public func select(item: EffectGroupItem, from source: EffectSource, completion: @escaping SelectionCallback) {
        guard currentEffectSources.contains(source) else {
            completion(Result.failure(EffectServiceError.sourceNotRegistered))
            return
        }
        
        source.getResult(for: item)
            .sink { result in
                switch result {
                case .finished:
                    return
                case .failure(_):
                    completion(Result.failure(EffectServiceError.itemSelectionFailed))
                }
            } receiveValue: { [weak self] itemResult in
                switch itemResult {
                case .bufferProcessor(let proccessor):
                    self?.transformController.processorStack.add(proccessor)
                case .transformLayer(let layer):
                    self?.transformController.layerStack.add(layer)
                case .noEffect:

                    break
                }
                completion(Result.success(()))
            }
            .store(in: &subs)
    }
}
