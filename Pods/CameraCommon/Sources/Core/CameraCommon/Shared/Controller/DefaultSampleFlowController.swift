import Combine
import CoreMedia

/// The default implementation of the `SampleFlowController` protocol.
///
public class DefaultSampleFlowController: SampleFlowController {
    
    private(set) public var isActive: Bool = false
    
    private(set) public var sources: [SampleSource] = []
    private(set) public var display: DisplayOutput?
    private(set) public var output: SampleOutput
    
    public var delegate: SampleFlowControllerDelegate?
    
    private var transformController: TransformController?
    private let orientationService: OrientationService
        
    /// Keep subscriptions associated with their source.
    private var sourceSubscriptions: [UUID: AnyCancellable] = [:]
    
    /// Make sure there are no race conditions modifying the source collections.
    private var sourceModificationQueue = DispatchQueue(label: "sourceModificationQueue", qos: .default)

    public init(
        display: DisplayOutput?,
        output: SampleOutput,
        transformController: TransformController?,
        orientationService: OrientationService
    ){
        self.display = display
        self.output = output
        self.transformController = transformController
        self.orientationService = orientationService
    }
    
    public func addSource(_ source: SampleSource) throws {
        guard !isActive else { throw SampleFlowControllerError.cannotChangeConfigurationWhileActive }
        let newSource = source.samples
        
        // Handle source errors.
            .mapError { [weak self] error in
                if
                    let self = self,
                    let delegate = self.delegate
                {
                    delegate.flowController(self, didEncounterError: error, fromSource: source)
                }
                return SampleFlowControllerError.failedToProcessSample
            }
        
        // Send the sample through the TransformController, if it is available.
            .flatMap { [weak self] sample -> AnyPublisher<CMSampleBuffer, SampleFlowControllerError> in
                guard
                    let tfc = self?.transformController,
                    let orientation = self?.orientationService.currentOrientation
                else {
                    return Just(sample).setFailureType(to: SampleFlowControllerError.self).eraseToAnyPublisher()
                }
                return tfc.transform(buffer: sample, orientation: orientation)
                    .mapError { _ in
                        // TODO: Handle error cases?
                        SampleFlowControllerError.failedToProcessSample
                    }
                    .eraseToAnyPublisher()
            }
        
        // Send the sample to the display, if present.
            .map { [weak self] sample -> CMSampleBuffer in
                self?.display?.output(sample: sample)
                return sample
            }
        
        // Send the sample to outputs. If any of the outputs fail, the entire flow fails.
            .flatMap { [weak self] sample -> AnyPublisher<Void, SampleFlowControllerError> in
                guard let output = self?.output else {
                    return Fail<Void, SampleFlowControllerError>(error: SampleFlowControllerError.failedToOutputSample)
                        .eraseToAnyPublisher()
                }
                return output.output(sample: sample)
                    .mapError({ [weak self] error in
                        if
                            let self = self,
                            let delegate = self.delegate
                        {
                            delegate.flowController(self, didEncounterError: error, fromOutput: output)
                        }
                        return SampleFlowControllerError.failedToOutputSample
                    })
                    .eraseToAnyPublisher()
            }
        
        // Check for failures.
            .sink { [weak self] completion in
                guard let self = self else { return }
                if
                    completion == .finished,
                    let delegate = self.delegate
                {
                    delegate.flowController(self, sourceDidComplete: source)
                }
                
                self.sources = self.sources.filter({ $0.id == source.id })
            } receiveValue: { _ in }
        
        sourceModificationQueue.async {
            self.sourceSubscriptions[source.id] = newSource
            self.sources.append(source)
        }
    }
    
    public func setDisplay(_ display: DisplayOutput?) throws {
        guard !isActive else { throw SampleFlowControllerError.cannotChangeConfigurationWhileActive }
        self.display = display
    }
    
    public func setOutput(_ output: SampleOutput) throws {
        guard !isActive else { throw SampleFlowControllerError.cannotChangeConfigurationWhileActive }
        self.output = output
    }
    
    public func removeSource(_ source: SampleSource) throws {
        guard !isActive else { throw SampleFlowControllerError.cannotChangeConfigurationWhileActive }
        sourceModificationQueue.async {
            self.sourceSubscriptions[source.id] = nil
            self.sources = self.sources.filter { $0.id == source.id }
        }
    }
        
    public func start() {
        guard !isActive else { return }
        isActive = true
        sources.forEach { $0.start() }
    }
    
    public func stop() {
        guard isActive else { return }
        sources.forEach { $0.stop() }
        isActive = false
    }
}
