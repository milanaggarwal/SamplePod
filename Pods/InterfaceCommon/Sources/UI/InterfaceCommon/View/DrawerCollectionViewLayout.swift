import UIKit


/// Defines a type that can provide cell size information to the `DefaultDrawerCollectionViewLayout`
public protocol DefaultDrawerCollectionViewLayoutDelegate: AnyObject {
    /// Returns the size of the item at the given index path
    func itemSizeAtIndexPath(_ indexPath: IndexPath) -> CGSize
}

/// Provides the layout for most of the content in the drawer
/// There is room for optimization in the layout calculations, mainly related to caching
/// However since the number of items in the layouts that this class handles are less than 20, optimization is being deferred for now.
public final class DefaultDrawerCollectionViewLayout: UICollectionViewLayout {
    public var itemType: ItemType = .tiles {
        didSet {
            invalidateLayout()
        }
    }
    
    public weak var delegate: DefaultDrawerCollectionViewLayoutDelegate?
    
    private var isLandscape: Bool {
        UIDevice.current.userInterfaceIdiom != .phone
    }
    
    /// The width available for layout of content based on the current size of the collection view
    private var availableContentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        let subtractingInsets = collectionView.bounds.width - (insets.left + insets.right)
        return max(subtractingInsets, 0.0)
    }
    
    private var contentHeight: CGFloat = 0
    
    private var attributesCache: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    
    public override var collectionViewContentSize: CGSize {
        CGSize(width: availableContentWidth, height: contentHeight)
    }
    
    public init(content: ItemType) {
        self.itemType = content
        super.init()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepare() {
        super.prepare()
        guard attributesCache.isEmpty else { return }
        contentHeight = contentHeight(forContentWidth: availableContentWidth)
        let itemSizes = self.itemSizes()
        guard !itemSizes.isEmpty else {
            // No items, nothing to layout
            return
        }
        
        if canLayoutInASingleRowWithContentWidth(availableContentWidth) {
            // We have enough room to lay out in a single row.
            setLayoutAttributesForSingleRowLayout(itemSizes: itemSizes)
        } else {
            // We will have to layout in multiple rows
            setLayoutAttributesForMultipleRowLayout(itemSizes: itemSizes)
        }
    }
    
    public override func invalidateLayout() {
        super.invalidateLayout()
        attributesCache = [:]
    }
    
    public override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
        attributesCache = [:]
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        // Probably a more efficient way to do this, but for the number of items in a drawer this should be fine
        // Loop through the cache and look for items in the rect
        for attributes in attributesCache.enumerated() {
            if attributes.element.value.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes.element.value)
            }
        }
        return visibleLayoutAttributes
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        attributesCache[indexPath]
    }
    
    /// Returns the width the layout would like to have in order to layout ideally
    public func preferredWidth() -> CGFloat? {
        if let staticPreferredWidth = itemType.staticPreferredWidth {
            return staticPreferredWidth
        }
        let itemSizes = self.itemSizes()
        guard !itemSizes.isEmpty else {
            // No sizes, no width
            return nil
        }
        let cellsWidth = itemSizes.reduce(-itemType.minimumInterItemSpacing) { $0 + $1.width + self.itemType.minimumInterItemSpacing }
        let totalWidth = cellsWidth
        return totalWidth
    }
    
    /// Returns the height of the content if it were asked to layout in the given width
    public func contentHeight(forContentWidth contentWidth: CGFloat) -> CGFloat {
        let itemSizes = self.itemSizes()
        guard !itemSizes.isEmpty else {
            // No item sizes, no height
            return 0
        }
        
        if canLayoutInASingleRowWithContentWidth(contentWidth) {
            // Single row, so let's return the height of the tallest cell
            let tallestCellHeight = itemSizes.reduce(0.0) { max($0, $1.height) }
            return tallestCellHeight
        } else {
            // More than one row, so we need to add up the heigh of all the rows.
            let rowHeight = multiLineLayoutRowHeightForItemSizes(itemSizes)
            let numberOfRows = multiLineLayoutNumberOfRows(forItemSizes: itemSizes, contentWidth: contentWidth)
            let rowHeights = Array(repeating: rowHeight, count: numberOfRows)
            let contentHeight = rowHeights.reduce(-itemType.interRowSpacing) { $0 + $1 + self.itemType.interRowSpacing }
            return max(0, contentHeight)
        }
    }
    
    /// Sets the layout attributes for the given items laid out in a single row
    private func setLayoutAttributesForSingleRowLayout(itemSizes: [CGSize]) {
        if itemType == .iconText {
            setLayoutAttributesForPrimaryDrawer(itemSizes: itemSizes)
            return
        }
        let height = itemSizes.reduce(0.0) { max($0, $1.height) }
        var nextCellXOrigin: CGFloat = 0.0
        itemSizes.enumerated().forEach { index, itemSize in
            let indexPath = IndexPath(item: index, section: 0)
            let itemSize = CGSize(width: itemSize.width, height: height)
            let frame = CGRect(origin: CGPoint(x: nextCellXOrigin, y: 0),
                               size: itemSize)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            attributesCache[indexPath] = attributes
            nextCellXOrigin += itemSize.width + itemType.minimumInterItemSpacing
        }
    }
    
    /// Sets the layout attributes for the given option/effects items laid out in a single row
    private func setLayoutAttributesForPrimaryDrawer(itemSizes: [CGSize]) {
        let height = itemSizes.reduce(0.0) { max($0, $1.height) }
        let cellWidth = largestWidth(inItemSizes: itemSizes)
        var nextCellXOrigin: CGFloat = 0.0
        let actualSpacing = (availableContentWidth - (CGFloat(itemSizes.count) * cellWidth)) / CGFloat(itemSizes.count - 1)
        itemSizes.enumerated().forEach { index, itemSize in
            let indexPath = IndexPath(item: index, section: 0)
            let itemSize = CGSize(width: cellWidth, height: height)
            let frame = CGRect(origin: CGPoint(x: nextCellXOrigin, y: 0),
                               size: itemSize)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            attributesCache[indexPath] = attributes
            nextCellXOrigin += itemSize.width + actualSpacing
        }
    }
    
    /// Sets the layout attributes for the given items laid out in multiple rows with equally spaced columns.
    private func setLayoutAttributesForMultipleRowLayout(itemSizes: [CGSize]) {
        let numberOfItemsPerRow = self.numberOfItemsPerRow(forContentWidth: availableContentWidth, itemSizes: itemSizes)
        let cellWidth = largestWidth(inItemSizes: itemSizes)
        let actualSpacing: CGFloat
        if numberOfItemsPerRow > 1 {
            actualSpacing = (availableContentWidth - (CGFloat(numberOfItemsPerRow) * cellWidth)) / CGFloat(numberOfItemsPerRow - 1)
        } else {
            // 1 or fewer items, no space
            actualSpacing = 0.0
        }
        let rowHeight = multiLineLayoutRowHeightForItemSizes(itemSizes)
        for item in 0 ..< itemSizes.count {
            let row = Int(floor(Double(item) / Double(numberOfItemsPerRow)))
            let column = item % numberOfItemsPerRow
            let indexPath = IndexPath(item: item, section: 0)
            let itemSize = CGSize(width: cellWidth, height: rowHeight)
            // The rows yOrigin is the row times the height of a row plus the spacing
            let rowYOrigin = CGFloat(row) * (rowHeight + itemType.interRowSpacing)
            // The cells x origin is the leading inset plus the column times the cells width plus spacing
            let cellXOrigin = (CGFloat(column) * (itemSize.width + actualSpacing))
            let frame = CGRect(origin: CGPoint(x: cellXOrigin, y: rowYOrigin),
                               size: itemSize)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            attributesCache[indexPath] = attributes
        }
    }
    
    /// Returns the height for a row in the a multiline layout for the given itemSizes
    private func multiLineLayoutRowHeightForItemSizes(_ itemSizes: [CGSize]) -> CGFloat {
        itemSizes.reduce(0.0) { max($0, $1.height) }
    }
    
    /// Returns the number of rows for the given items and contentWidth in a multi line layout
    private func multiLineLayoutNumberOfRows(forItemSizes itemSizes: [CGSize], contentWidth: CGFloat) -> Int {
        let numberOfItemsPerRow = self.numberOfItemsPerRow(forContentWidth: contentWidth, itemSizes: itemSizes)
        let numberOfItems = itemSizes.count
        return Int(ceil(Double(numberOfItems) / Double(numberOfItemsPerRow)))
    }
    
    /// Returns the number of items per row based on the available content width and the sizes of the items
    /// - Parameters:
    ///   - contentWidth: The width available for the layout
    ///   - itemSizes: The sizes of the items to be laid out
    private func numberOfItemsPerRow(forContentWidth contentWidth: CGFloat, itemSizes: [CGSize]) -> Int {
        if canLayoutInASingleRowWithContentWidth(contentWidth) {
            return itemSizes.count
        } else {
            let itemWidth = largestWidth(inItemSizes: itemSizes)
            // No spacing associated with the first item.
            let widthAfterFirstItem = contentWidth - itemWidth
            guard widthAfterFirstItem > itemWidth + itemType.minimumInterItemSpacing else {
                return 1
            }
            // The additional items that can be added is the remaining space divided by the item width plus the min spacing
            let numberOfAdditionalItems = widthAfterFirstItem / (itemWidth + itemType.minimumInterItemSpacing)
            // Return the additional items plus the first
            return Int(floor(numberOfAdditionalItems)) + 1
        }
    }
    
    /// Returns the width of the larget item in the given itemSizes
    private func largestWidth(inItemSizes itemSizes: [CGSize]) -> CGFloat {
        itemSizes.max(by: { $0.width < $1.width })?.width ?? 48
    }
    
    /// Returns whether or not the layouts preferred width is small enough to layout in a single row
    private func canLayoutInASingleRowWithContentWidth(_ contentWidth: CGFloat) -> Bool {
        contentWidth >= preferredWidth() ?? 0.0 && itemType.staticPreferredWidth == nil
    }
    
    /// Returns the sizes of the items that the collection view needs to display in order.
    private func itemSizes() -> [CGSize] {
        guard let collectionView = collectionView else {
            return []
        }
        // Only supports one section, for now at least
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        let sizes = Array(0 ..< numberOfItems)
            .map { IndexPath(row: $0, section: 0) }
            .map { self.itemSize(at: $0) }
        return sizes
    }
    
    /// Returns the size of the item at the given path
    private func itemSize(at indexPath: IndexPath) -> CGSize {
        switch itemType {
        case .tiles:
            return isLandscape ? CGSize(width: 80, height: 60) : CGSize(width: 60, height: 80)
        case .iconText:
            return delegate?.itemSizeAtIndexPath(indexPath) ?? CGSize(width: 40, height: 48)
        }
    }
}

// MARK: - Sub Models

extension DefaultDrawerCollectionViewLayout {
    public enum ItemType {
        case iconText
        case tiles
        
        var minimumInterItemSpacing: CGFloat {
            switch self {
            case .tiles:
                return 8
            case .iconText:
                return 24
            }
        }
        
        var interRowSpacing: CGFloat {
            switch self {
            case .tiles:
                return 8
            case .iconText:
                return 24
            }
        }
        
        var staticPreferredWidth: CGFloat? {
            switch self {
            case .tiles:
                return 375
            case .iconText:
                return nil
            }
        }
    }
}
