import Combine
import UIKit
import CameraCommon

/// Defines a type that can be a `Section` in the `SearchableItemsView`
public protocol SearchableCollectionViewSection: CategoryCollectionViewItem {
    /// Whether or not the given section should have a header displayed.
    var shouldDisplayHeaderForSection: Bool { get }
}

/// Defines a type that can be a `Section` in the `SearchableItemsView`
public protocol SearchableCollectionViewItem: Hashable {
    /// The mode with which the item should be displayed in the collection view
    var displayMode: SearchableCollectionViewItemDisplayMode { get }
    /// It defines whether there should be any inset in the view cell
    var shouldHaveImageInset: Bool {get}
    /// It defines whether the image inside the cell should fit in the cell or fill it
    var shouldHaveContentModeFit: Bool {get}
    /// The image of the effect in the cell
    var name: String? {get}
    /// The title to be announced for accessibility when selected
    var accessibilityLabel: String? {get}
    /// Unique identifier of the item in the cell
    var id: UUID {get}
    /// Publisher which captures different states of the item in the cell
    var statePublisher: AnyPublisher<SearchableCollectionViewItemState, Never> {get}
    /// Defines the state of the item if the particular effect item is being applied
    var state: SearchableCollectionViewItemState {get}
    /// Updates the state of the item when the effect is being applied in the recorder
    func setState(state: SearchableCollectionViewItemState) -> Void
    /// A boolean used to show if the item is currently selected or not
    var isSelected: Bool {get}
    /// Publisher to denote changes in the `isSelected`property of the item
    var isSelectedPublisher: AnyPublisher<Bool, Never> {get}
    /// It sets `isSelected` of the item
    func setIsSelected(isSelected: Bool) -> Void
}

/// Defines the config for the items to be shown in the drawer collection view
public protocol DrawerCollectionViewCellConfig {
    var numberOfItemsPerRow: Int {get set}
    var isSquaredItem: Bool {get set}
}

/// The different modes that can be used to display an item
public enum SearchableCollectionViewItemDisplayMode {
    /// Represents the case where the item will be displayed with an image only
    case imageOnly(AnyPublisher<UIImage, Error>)
}

/// The class extended by all types of view cells to be used in the collection view. It defines the common methods to be used in all the extended view cells.
open class DrawerCollectionViewCell: UICollectionViewCell, Reusable {
    public static var reuseIdentifier: String {
        String(describing: self)
    }
    
    /// This method initialises the viewmodel inside different types of cells used in the drawer collection view. It should implement the subscribers needed to show different UI states in the respective cells
    /// - Parameters:
    ///     - withViewModel: The view model defining the visual state of the respective cell
    public func set(withViewModel: DrawerEffectCellCollectionViewModel) {
        fatalError("Method not implemented")
    }
}

/// View that displays a collection of searchable sectioned items
public final class SearchableCollectionView<Section: SearchableCollectionViewSection, Item: SearchableCollectionViewItem, Cell: DrawerCollectionViewCell>: UIView, UICollectionViewDelegate, UIScrollViewDelegate{
    
    typealias DiffableDataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    public var searchTerm: String? {
        guard isSearchEnabled else {
            return nil
        }
        return searchBar.searchTerm
    }
    
    public var searchTermPublisher: AnyPublisher<String?, Never> {
        searchBar.searchTermPublisher
            .filter {[weak self] _ in return self?.isSearchEnabled ?? false }
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    public var itemSelectedPublisher: AnyPublisher<Item, Never> {
        itemSelectedSubject.eraseToAnyPublisher()
    }
    
    private let isSearchEnabled: Bool
    private let padding: CGFloat = 16
    
    private lazy var itemSelectedSubject: PassthroughSubject<Item, Never> = PassthroughSubject()
    
    private lazy var searchTermSubject: PassthroughSubject<String?, Never> = PassthroughSubject()
    
    private lazy var searchAndCategoriesStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var searchBar: SearchBarView = {
        let bar = SearchBarView()
        bar.isHidden = !isSearchEnabled
        return bar
    }()
    
    private lazy var categoryCollectionView: CategoryCollectionView<Section> = {
        let headerView = CategoryCollectionView<Section>()
        return headerView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        collectionView.register(SearchableCollectionSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SearchableCollectionSectionHeaderView.reuseIdentifier)
        collectionView.backgroundColor = .clear
        collectionView.keyboardDismissMode = .interactive
        collectionView.delegate = self
        (collectionView as UIScrollView).delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var collectionViewLayout: UICollectionViewCompositionalLayout = {
        let width = 1.0 / CGFloat(numberOfItemsPerRow + 1)
        let heightRatio = isSquaredItem ? 1.0 : (4.0/3.0)
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(width), heightDimension: .fractionalWidth(heightRatio * width))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(heightRatio * width))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = NSCollectionLayoutSpacing.flexible(width)
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(40))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)

        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]

        section.contentInsets = NSDirectionalEdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding)
        section.interGroupSpacing = width * 100

        return UICollectionViewCompositionalLayout(section: section)
    }()
    
    private lazy var collectionViewDataSource: DiffableDataSource = {
        var dataSource = DiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as? Cell else {
                fatalError("Could not dequeue cell with identifier: \(Cell.reuseIdentifier)")
            }
            cell.set(withViewModel: DefaultDrawerEffectCellCollectionViewModel<Item>(item: item , accessibilityPosition: indexPath.row + 1))
            return cell
        }
        
        //Header Views
        dataSource.supplementaryViewProvider = {[weak dataSource] (collectionView, kind, indexPath) -> UICollectionReusableView? in
            guard kind == UICollectionView.elementKindSectionHeader,
                  let dataSource = dataSource,
                  let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SearchableCollectionSectionHeaderView.reuseIdentifier, for: indexPath) as? SearchableCollectionSectionHeaderView else {
                      preconditionFailure("Only header views are currently supported")
                  }
            
            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            view.sectionName = section.displayName
            return view
        }
        return dataSource
    }()
    
    private lazy var cancellables: Set<AnyCancellable> = Set()
    
    private let numberOfItemsPerRow: Int
    private let isSquaredItem: Bool

    /// Whether or not the scroll view is currently being scrolled to a specific section
    private var isCurrentlyScrollingToSection: Bool = false
    /// Tracks whether or not the user started the current scroll with a swipe or a drag
    private var userStartedCurrentScroll: Bool = false
    
    public init(isSearchEnabled: Bool, sectionedItems: [(Section, [Item])], config: DrawerCollectionViewCellConfig) {
        self.isSearchEnabled = isSearchEnabled
        self.numberOfItemsPerRow = config.numberOfItemsPerRow
        self.isSquaredItem = config.isSquaredItem
        super.init(frame: .zero)
        setUpView()
        set(sectionedItems: sectionedItems, animated: false)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Sets the collection with the given sections and items
    /// - Parameters:
    ///   - sectionedItems: The sections and items to be displayed in the collection view
    ///   - animated: Whether or not the data reload should be animated
    public func set(sectionedItems: [(Section, [Item])], animated: Bool) {
        var snapshot = Snapshot()
        sectionedItems.forEach { (section, items) in
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
        }
        collectionViewDataSource.apply(snapshot, animatingDifferences: animated)
        categoryCollectionView.categories = sectionedItems.map { $0.0 }
        setCategoriesView(hidden: sectionedItems.count <= 1, animated: animated)
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = collectionViewDataSource.itemIdentifier(for: indexPath) else { return }
        itemSelectedSubject.send(item)
    }
    
    //MARK: - View Setup
    
    private func setUpView() {
        backgroundColor = .clear
        addSubview(searchAndCategoriesStack)
        addSubview(collectionView)
        searchAndCategoriesStack.addArrangedSubview(searchBar)
        searchAndCategoriesStack.addArrangedSubview(categoryCollectionView)
        
        NSLayoutConstraint.activate([
            searchAndCategoriesStack.topAnchor.constraint(equalTo: topAnchor),
            searchAndCategoriesStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchAndCategoriesStack.trailingAnchor.constraint(equalTo: trailingAnchor).withPriority(.almostRequired),
            
            searchBar.widthAnchor.constraint(equalTo: searchAndCategoriesStack.widthAnchor, constant: -(padding * 2)),
            categoryCollectionView.widthAnchor.constraint(equalTo: searchAndCategoriesStack.widthAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchAndCategoriesStack.bottomAnchor, constant: padding),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).withPriority(.almostRequired),
        ])
        
        setUpSubscriptions()
    }
    
    private func setUpSubscriptions() {
        categoryCollectionView.categoryTappedPublisher
            .sink {[weak self] category in
                guard let self = self else { return }
                self.scroll(to: category)
            }.store(in: &cancellables)
    }
    
    private func setCategoriesView(hidden: Bool, animated: Bool) {
        guard categoryCollectionView.isHidden != hidden else { return }
        
        guard animated else {
            categoryCollectionView.isHidden = hidden
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            self.categoryCollectionView.isHidden = hidden
            self.searchAndCategoriesStack.layoutIfNeeded()
        }
    }
    
    private func scroll(to section: Section) {
        guard !userStartedCurrentScroll else { return }
        let sectionIndex: Int
        if #available(iOS 15.0, *) {
            guard let indexForSection = collectionViewDataSource.index(for: section) else { return }
            sectionIndex = indexForSection
        } else {
            guard let indexForSection = collectionViewDataSource.snapshot().sectionIdentifiers.firstIndex(of: section) else { return }
            sectionIndex = indexForSection
        }
        guard let attributes = collectionView.collectionViewLayout.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: sectionIndex)) else { return }
        
        let updatedContentOffset = CGPoint(x: 0, y: attributes.frame.origin.y - collectionView.contentInset.top)
        guard collectionView.contentOffset.y != updatedContentOffset.y else { return }
        isCurrentlyScrollingToSection = true
        collectionView.setContentOffset(updatedContentOffset, animated: true)
        categoryCollectionView.set(selectedCategory: section)
    }
    
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isCurrentlyScrollingToSection = false
        userStartedCurrentScroll = true
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if abs(velocity.y) < 1.0 {
            // If velocity is too low, scrollViewDidEndDecelerating will not be called, so we need to set scroll state here
            userStartedCurrentScroll = false
        }
    }
    
    public func scrollViewDidScroll(_: UIScrollView) {
        let offset = CGPoint(x: collectionView.bounds.width / 2, y: collectionView.contentOffset.y)
        if !isCurrentlyScrollingToSection,
           userStartedCurrentScroll,
           let indexPath = collectionView.indexPathForItem(at: offset)
        {
            let section = collectionViewDataSource.snapshot().sectionIdentifiers[indexPath.section]
            categoryCollectionView.set(selectedCategory: section)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isCurrentlyScrollingToSection = false
        userStartedCurrentScroll = false
    }
}
