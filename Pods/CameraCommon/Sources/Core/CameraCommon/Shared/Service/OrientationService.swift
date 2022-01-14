import Combine
import UIKit

/// An OrientationService provides real-time information about the device's orientation.
///
public protocol OrientationService: AnyObject {
    
    /// A publisher which emits the current device orientation.
    ///
    var orientation: AnyPublisher<Orientation, Never> { get }
    
    /// The current orientation for the app.
    var currentOrientation: Orientation { get }
}

/// The default implementation of the `OrientationService` protocol.
///
public final class DefaultOrientationService: NSObject, OrientationService {
    
    /// The current orientation value.
    public var currentOrientation: Orientation { _orientation.value }

    /// The actual publisher behind the orientation.
    private var _orientation = CurrentValueSubject<Orientation, Never>(.portrait)

    /// Publisher for the current device orientation.
    public var orientation: AnyPublisher<Orientation, Never> { _orientation.eraseToAnyPublisher() }

    private var cancellable: Cancellable?

    /// Create an instance of the default orientation service.
    public override init() {
        super.init()
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        self.cancellable = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification).map { _ in
            UIDevice.current.orientation
        }.filter { orientation in
            orientation.isValidInterfaceOrientation
        }.removeDuplicates().eraseToAnyPublisher().sink { [weak self] orientation in
            guard let self = self else { return }
            self.onOrientationChanged(orientation: orientation)
        }
    }

    deinit {
        cancellable?.cancel()
    }

    /// Send out the new orientation.
    ///
    private func onOrientationChanged(orientation: UIDeviceOrientation) {
        _orientation.send(Orientation(deviceOrientation: orientation))
    }
}
