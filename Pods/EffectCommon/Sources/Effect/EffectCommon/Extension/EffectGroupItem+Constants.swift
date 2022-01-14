import CameraCommon
import UIKit

public extension EffectGroupItem {
    
    /// A static EffectGroupItem for the "Cancel" action.
    ///
    /// This getter is safe using `try!` because this initializer won't throw as long as at least one of
    /// name, iconImage or iconAltImage is non-nil.
    ///
    static let cancel = try! EffectGroupItem(id: UUID(),
                                             name: "Cancel",
                                             iconImage: Asset.cancel.image,
                                             iconAltImage: nil,
                                             isCancelItem: true)

    /// A static function to return the EffectGroupItem for the "Cancel" button.
    /// A different "Cancel" button is needed to be created for each effect to show if it is currently selected
    static func getCancelItem() -> EffectGroupItem {
        return try! EffectGroupItem(id: UUID(),
                              name: "Cancel",
                              iconImage: Asset.cancel.image,
                              iconAltImage: nil,
                              isCancelItem: true)
    }
}
