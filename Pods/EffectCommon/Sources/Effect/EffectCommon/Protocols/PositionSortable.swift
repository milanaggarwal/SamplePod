import Foundation

/// Enables implementation to be sorted on position basis
public protocol PositionSortable {
    var position: Int { get }
}

extension Array where Element: PositionSortable {
    public func sortedByPosition() -> Self {
        sorted(by: { $0.position < $1.position })
    }

    public mutating func sortByPosition() {
        sort(by: { $0.position < $1.position })
    }
}
