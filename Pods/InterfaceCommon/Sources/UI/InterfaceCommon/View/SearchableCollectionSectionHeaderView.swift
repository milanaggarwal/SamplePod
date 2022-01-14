import UIKit

/// Header view that is used for sections in the `SearchableCollectionView`
public final class SearchableCollectionSectionHeaderView: UICollectionReusableView, Reusable {
    public static var reuseIdentifier: String {
        String(describing: Self.self)
    }
    
    public var sectionName: String? {
        didSet {
            sectionNameLabel.text = sectionName
        }
    }
    
    private lazy var sectionNameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        backgroundColor = .clear
        
        addSubview(sectionNameLabel)
        NSLayoutConstraint.activate([
            sectionNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            sectionNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            sectionNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            sectionNameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
        ])
    }
    
}
