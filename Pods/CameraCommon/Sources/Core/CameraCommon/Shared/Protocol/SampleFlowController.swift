import CoreMedia
import Combine

/// Controls the flow of samples from input to output.
///
public protocol SampleFlowController: AnyObject {
    
    /// Indicates whether or not the flow is currently active (moving samples).
    var isActive: Bool { get }
    
    /// A list of sources that can emit samples into the flow.
    var sources: [SampleSource] { get }
    
    /// The final output for all samples.
    var output: SampleOutput { get }
    
    /// A delegate object that can monitor the health of the flow.
    var delegate: SampleFlowControllerDelegate? { get set }
    
    /// Add a new source to the flow.
    ///
    /// The flow controller must be inactive (stopped) before changes can be made to the configuration.
    ///
    /// - Parameter source: The `SampleSource` to add to the flow.
    /// - Throws: `SampleFlowControllerError.cannotChangeConfigurationWhileActive` if method is called while the controller is active.
    ///
    func addSource(_ source: SampleSource) throws
    
    /// Remove a source from the flow.
    ///
    /// The flow controller must be inactive (stopped) before changes can be made to the configuration.
    ///
    /// - Parameter source: The `SampleSource` to remove from the flow.
    /// - Throws: `SampleFlowControllerError.cannotChangeConfigurationWhileActive` if method is called while the controller is active.
    ///
    func removeSource(_ source: SampleSource) throws
    
    /// Set the display output.
    ///
    /// The flow controller must be inactive (stopped) before changes can be made to the configuration.
    ///
    /// - Parameter display: The `DisplayOutput` to set on the controller.
    /// - Throws: `SampleFlowControllerError.cannotChangeConfigurationWhileActive` if method is called while the controller is active.
    ///
    func setDisplay(_ display: DisplayOutput?) throws
    
    /// Set a new output to the flow.
    ///
    /// The flow controller must be inactive (stopped) before changes can be made to the configuration.
    ///
    /// - Parameter output: The `SampleOutput` to set on the flow.
    /// - Throws: `SampleFlowControllerError.cannotChangeConfigurationWhileActive` if method is called while the controller is active.
    ///
    func setOutput(_ output: SampleOutput) throws
    
    /// Make the flow active.
    ///
    /// Calls the `start()` method on all 
    func start()
    
    /// Make the flow inactive.
    func stop()
}

/// Allows an object to monitor the high-level health of the sample flow.
///
public protocol SampleFlowControllerDelegate: AnyObject {
    /// A method that is invoked when a sample source encounters an error.
    ///
    /// - Parameters:
    ///     - sampleFlowController: The flow controller invoking this method.
    ///     - error: The error that was encountered.
    ///     - source: The `SampleSource` which produced the error.
    ///
    func flowController(_ sampleFlowController: SampleFlowController, didEncounterError error: Error, fromSource source: SampleSource)
    
    /// A method that is invoked when a sample source indicates it is complete.
    ///
    /// - Parameters:
    ///     - sampleFlowController: The flow controller invoking this method.
    ///     - source: The `SampleSource` which completed.
    func flowController(_ sampleFlowController: SampleFlowController, sourceDidComplete source: SampleSource)
    
    /// A method that is invoked when a sample output encounters an error.
    func flowController(_ sampleFlowController: SampleFlowController, didEncounterError error: Error, fromOutput output: SampleOutput)
}
