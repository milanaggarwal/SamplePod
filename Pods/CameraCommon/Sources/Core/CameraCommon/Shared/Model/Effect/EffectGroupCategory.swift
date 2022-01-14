import UIKit
import Combine

/// This is an intermediate type that allows an `EffectGroup` with a large number of items
/// to organize them into semantic categories.
///
public struct EffectGroupCategory: Identifiable {
    
    /// The unique identifier of this category.
    public let id: UUID
    
    /// The title for this category.
    public let title: String
    
    /// The optional icon for this category.
    public let icon: AnyPublisher<UIImage, EffectGroupError>?
    
    /// The items within this category.
    public let items: [EffectGroupItem]
    
    public init(id: UUID = UUID(), title: String, icon: AnyPublisher<UIImage, EffectGroupError>?, items: [EffectGroupItem]) {
        self.id = id
        self.title = title
        self.icon = icon
        self.items = items
    }
}

// MARK: - Equatable & Hashable

extension EffectGroupCategory: Hashable {
    
    public static func ==(lhs: EffectGroupCategory, rhs: EffectGroupCategory) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
