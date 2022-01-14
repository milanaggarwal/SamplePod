import Foundation
import CameraCommon
import CoreImage
import Combine
import EffectBitmapOverlay
import InterfaceCommon
import UIKit

/// Handles effect sources for pen effect
///
public final class PenEffectSourceHandler {
    
    /// The orientation service.
    private let orientationService: OrientationService
    
    /// Instantiate `PenManager`.
    public init(orientationService: OrientationService) {
        self.orientationService = orientationService
    }
}

// MARK: - EffectSource
extension PenEffectSourceHandler {
    
    public func effectSource() -> EffectSource {
        let group = EffectGroup(name: name, icon: iconPublisher, effectItem: item)
        return EffectSource(name: name, iconPublisher: iconPublisher, group: group) { [weak self] item in
            guard let self = self else {
                return Fail<EffectSource.ItemResult, EffectGroupError>(error: EffectGroupError.unableToCreateTransformLayer)
                    .eraseToAnyPublisher()
            }
            
            let effect = PenEffectLayer(withSize: VideoResolution.halfHD.portraitSize, orientation: self.orientationService.currentOrientation)
            
            return Just(EffectSource.ItemResult.transformLayer(effect))
                .setFailureType(to: EffectGroupError.self)
                .eraseToAnyPublisher()
        }
    }
    
    private var name: String {
        return InterfaceStrings.Pen.pen
    }
    
    private var iconPublisher: AnyPublisher<Result<ImageAsset.Image, EffectGroupError>.Publisher.Output, EffectGroupError> {
        return Just(Asset.penIcon.image)
            .setFailureType(to: EffectGroupError.self)
            .eraseToAnyPublisher()
    }
    
    private var item: EffectGroupItem {
        do {
            return try EffectGroupItem(name: name,
                                       iconImage: Asset.penIcon.image,
                                       iconAltImage: nil)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
}
