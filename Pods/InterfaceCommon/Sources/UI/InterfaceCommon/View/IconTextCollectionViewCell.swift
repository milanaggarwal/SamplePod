import Combine
import UIKit

/// Collection View Cell that houses an `IconTextButton`
public final class IconTextCollectionViewCell: DrawerCollectionViewCell {
    
    private(set) var button: IconTextButton?
    
    private var viewModel: DrawerEffectCellCollectionViewModel?

    public override var isSelected: Bool {
        didSet {
            if button?.isEnabled ?? false {
                button?.isSelected = self.isSelected
                self.accessibilityTraits = self.isSelected ? [.selected, .button] : .button
            }
        }
    }
    
    public override var isHighlighted: Bool {
        didSet {
            button?.isHighlighted = self.isHighlighted
        }
    }
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var cancellables: Set<AnyCancellable> = Set()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        contentView.addSubview(loadingIndicator)
        loadingIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = .clear
        contentView.addSubview(loadingIndicator)
        loadingIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        button?.removeFromSuperview()
        button = nil
        isUserInteractionEnabled = true
        cancellables = Set()
    }
    
    public func set(image: UIImage, text: String?) {
        let button = IconTextButton(image: image, text: text, showsSelectedState: true)
        if let _ = text {
            button.maxImageSize = CGSize(width: 32, height: 32)
        } else {
            button.maxImageSize = nil
        }
        button.set(supportsDynamicType: true)
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).withPriority(.almostRequired),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).withPriority(.almostRequired),
        ])
        self.button = button
        isAccessibilityElement = true
        accessibilityLabel = button.accessibilityLabel
        accessibilityHint = button.accessibilityHint
        accessibilityTraits = isSelected ? [.selected, .button] : .button
        
        largeContentTitle = text
        largeContentImage = image
        showsLargeContentViewer = true
        addInteraction(UILargeContentViewerInteraction())
    }
    
    public func set(imagePublisher: AnyPublisher<UIImage, Error>, text: String?) {
        loadingIndicator.startAnimating()
        imagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                #warning("Handle this")
                self.loadingIndicator.stopAnimating()
            } receiveValue: {[weak self] image in
                guard let self = self else { return }
                self.set(image: image, text: text)
                self.loadingIndicator.stopAnimating()
            }.store(in: &cancellables)
    }
    public override func set(withViewModel viewModel: DrawerEffectCellCollectionViewModel) {
        loadingIndicator.startAnimating()
        self.viewModel = viewModel
        viewModel.imagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                #warning("Handle this")
                self.loadingIndicator.stopAnimating()
            } receiveValue: {[weak self] image in
                guard let self = self else { return }
                self.set(image: image, text: nil)
                self.loadingIndicator.stopAnimating()
            }.store(in: &cancellables)
    }
}
