import Combine
import UIKit

/// Defines a type that can be displayed in the `CategoryCollectionView`
public protocol CategoryCollectionViewItem: Hashable {
    var displayName: String { get }
}

/// A horizontally scrolling collection view that displays selectable items
public class CategoryCollectionView<Item: CategoryCollectionViewItem>: UICollectionView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    typealias CollectionSnapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    public enum Section: Hashable {
        case main
    }
    
    public private(set) var selectedCategory: Item?
    
    public var categories = [Item]() {
        didSet {
            guard Thread.isMainThread else {
                assertionFailure("This should only be called from the main thread")
                return
            }
            guard !categories.isEmpty else {
                #warning("Is filtering out empty values going to have unexpected side-effects?")
                return
            }
            if oldValue.isEmpty {
                selectedCategory = categories.first
            }
            var snapshot = CollectionSnapshot()
            snapshot.appendSections([.main])
            snapshot.appendItems(categories, toSection: .main)
            collectionViewDataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    /// Publisher that will fire whenever the user taps a category
    public var categoryTappedPublisher: AnyPublisher<Item, Never> {
        _categoryTappedPublisher
            .eraseToAnyPublisher()
    }
    
    private lazy var _categoryTappedPublisher: PassthroughSubject<Item, Never> = PassthroughSubject()
    
    private lazy var collectionViewDataSource: UICollectionViewDiffableDataSource<Section, Item> = {
        UICollectionViewDiffableDataSource<Section, Item>(collectionView: self) { [weak self] collectionView, indexPath, item in
            guard let self = self else {
                assertionFailure("This path shouldn't happen, why are cells being vended if the vc has be released?")
                return UICollectionViewCell()
            }
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier, for: indexPath) as? CategoryCollectionViewCell else {
                preconditionFailure("Collection view not configured properly")
            }
            
            cell.set(text: item.displayName, isSelected: self.selectedCategory == item)
            return cell
        }
    }()
    
    private let layoutCell = CategoryCollectionViewCell()
    private lazy var heightConstraint = heightAnchor.constraint(equalToConstant: 50)
    
    private lazy var sizeCache: [SizeCacheKey: CGSize] = [:]
    
    public init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 20
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.sectionInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        super.init(frame: CGRect.zero, collectionViewLayout: layout)
        setupCollectionView()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func set(selectedCategory: Item?) {
        guard Thread.isMainThread else {
            assertionFailure("This should only be called from the main thread")
            return
        }
        
        let oldValue = self.selectedCategory
        guard selectedCategory != oldValue else { return }
        self.selectedCategory = selectedCategory
        var itemsToReload: [Item] = []
        if let oldItem = oldValue, let _ = collectionViewDataSource.indexPath(for: oldItem) {
            itemsToReload.append(oldItem)
        }
        if let newItem = selectedCategory, let indexPath = collectionViewDataSource.indexPath(for: newItem) {
            itemsToReload.append(newItem)
            scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        var snapshot = collectionViewDataSource.snapshot()
        snapshot.reloadItems(itemsToReload)
        collectionViewDataSource.apply(snapshot, animatingDifferences: false, completion: nil)
    }
    
    private func setupCollectionView() {
        accessibilityTraits.insert(.header)
        delegate = self
        showsHorizontalScrollIndicator = false
        backgroundColor = .clear
        register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier)
        heightConstraint.isActive = true
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        _categoryTappedPublisher.send(category)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let category = categories[indexPath.row]
        let preferredContentSize = UIApplication.shared.preferredContentSizeCategory
        if let cached = sizeCache[SizeCacheKey(contentSizeCategory: preferredContentSize, item: category)] {
            return cached
        }
        
        layoutCell.prepareForReuse()
        layoutCell.set(text: category.displayName, isSelected: true)
        layoutCell.setNeedsLayout()
        layoutCell.layoutIfNeeded()
        let cellSize = layoutCell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        // Update current height anchor
        let cellHeight = cellSize.height
        let currentHeight = heightConstraint.constant
        let newHeight = max(cellHeight, currentHeight)
        if newHeight != currentHeight {
            heightConstraint.constant = newHeight
            setNeedsLayout()
        }
        sizeCache[SizeCacheKey(contentSizeCategory: preferredContentSize, item: category)] = cellSize
        return cellSize
    }
    
    struct SizeCacheKey: Hashable {
        let contentSizeCategory: UIContentSizeCategory
        let item: Item
    }
}

// MARK: - Cell

public final class CategoryCollectionViewCell: UICollectionViewCell, Reusable {
    static var reuseIdentifier: String {
        String(describing: Self.self)
    }
    
    private static let dotDiameter: CGFloat = 8
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dotView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = Self.dotDiameter / 2
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: Self.dotDiameter),
            view.heightAnchor.constraint(equalToConstant: Self.dotDiameter),
        ])
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func set(text: String, isSelected: Bool) {
        label.text = text
        label.textColor = isSelected ? .white : .gray
        dotView.isHidden = !isSelected
    }
    
    private func setUpView() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(label)
        contentView.addSubview(dotView)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            dotView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            dotView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dotView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2).withPriority(.almostRequired),
        ])
    }
}
