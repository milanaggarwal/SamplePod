import Foundation
import Combine

public protocol AssembleController: AnyObject {
    var project: VideoProject { get }
    
    var trackController: TrackController { get }
    
    func renderVideo() -> AnyPublisher<URL, AssembleControllerError>
}

final public class DefaultAssembleController: AssembleController {
    
    private(set) public var project: VideoProject
    
    public let trackController: TrackController
    
    public init(project: VideoProject, trackController: TrackController = DefaultTrackController()) {
        self.project = project
        self.trackController = trackController
    }
    
    public func renderVideo() -> AnyPublisher<URL, AssembleControllerError> {
        Fail(error: AssembleControllerError.unableToRenderVideo).eraseToAnyPublisher()
    }
    
}
