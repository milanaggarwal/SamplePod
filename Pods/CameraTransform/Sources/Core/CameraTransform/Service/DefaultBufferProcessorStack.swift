import AVFoundation
import Combine
import CameraCommon

public final class DefaultBufferProcessorStack: BufferProcessorStack {
    
    public var layerEventPublisher: AnyPublisher<BufferProcessorStackEvent, Never> {
        _layerEventPublisher
            .eraseToAnyPublisher()
    }
    private lazy var _layerEventPublisher = PassthroughSubject<BufferProcessorStackEvent, Never>()
    
    private(set) public var isBusy: Bool = false
    
    /// Store the processors. Treated as a queue for processing purposes.
    private(set) public var processors: [BufferProcessor] = []
    
    /// The index of the processor to invoke.
    private var processorIndex = 0
        
    /// Returns the number of processors currently being managed.
    public var count: Int { processors.count }
    
    public init() {
        // Nothing, yet.
    }
    
    public func add(_ processor: BufferProcessor) {
        guard processors.first(where: { $0.id == processor.id }) == nil else { return }
        _layerEventPublisher.send(.willAdd(processor))
        processors.append(processor)
        _layerEventPublisher.send(.didAdd(processor))
    }
    
    public func remove(_ processor: BufferProcessor) {
        _layerEventPublisher.send(.willRemove(processor))
        processors = processors.filter({ $0.id != processor.id })
        _layerEventPublisher.send(.didRemove(processor))
    }

    public func process(buffer: CMSampleBuffer, orientation: Orientation) -> AnyPublisher<CMSampleBuffer, BufferProcessorStackError> {
        let just = Just(buffer)
            .setFailureType(to: BufferProcessorStackError.self)
            .eraseToAnyPublisher()
        guard !processors.isEmpty else {
            return just
        }
        let logId = Logger.shared.startPerformanceTrace(label: "buffer-stack-process")
        processors.forEach { if $0.shouldRemoveProcessor { $0.prepareForRemoval() } }
        processors = processors.filter { !$0.shouldRemoveProcessor }
        // Chain all of the publishers
        return processors.reduce(just) { (publisher, processor)  in
            publisher.flatMap { buffer -> AnyPublisher<CMSampleBuffer, BufferProcessorStackError> in
                let result = processor.process(buffer: buffer, orientation: orientation)
                    .setFailureType(to: BufferProcessorStackError.self)
                    .eraseToAnyPublisher()
                Logger.shared.logPerformanceEvent(label: processor.debugName)
                return result
            }
            // Set the `isBusy` property back to false when the final publisher in the chain emits a value.
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.isBusy = false
                Logger.shared.endPerformanceTrace(id: logId)
            })
            .eraseToAnyPublisher()
        }
    }
    
}
