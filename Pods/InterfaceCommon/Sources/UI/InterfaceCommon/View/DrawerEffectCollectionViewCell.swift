import Combine
import UIKit

/// Defines the data needed to drive the `EffectCollectionViewCell`
public protocol DrawerEffectCellCollectionViewModel {
    /// The image to be displayed in the cell
    var image: UIImage? { get set }
    var imagePublisher: AnyPublisher<UIImage, Error> { get }

    /// The content mode do display the image with
    var imageContentMode: UIImageView.ContentMode { get }
    var imageContentModePublisher: AnyPublisher<UIImageView.ContentMode, Never> { get }

    /// How much the image should be inset from the edge of the cell
    var imageInsets: UIEdgeInsets { get }
    var imageInsetsPublisher: AnyPublisher<UIEdgeInsets, Never> { get }

    /// Whether or not the cell is in a loading state
    var isLoading: Bool { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }

    /// Whether or not the cell is currently selected
    var isSelected: Bool { get }
    var isSelectedPublisher: AnyPublisher<Bool, Never> { get }

    /// The accessibility label for the cell
    var accessibilityLabel: String { get }
    var accessibilityLabelPublisher: AnyPublisher<String, Never> { get }

    /// Cancels any in progress image loading for the cell
    func cancelImageLoad()
}

/// Generalized collection view cell used for displaying an effect that can be applied to a video
/// Driven by a `DrawerEffectCellCollectionViewModel`
final public class DrawerEffectCollectionViewCell: DrawerCollectionViewCell {
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.color = .white
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = InterfaceCommonColors.borderShadow.color
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var selectedBorderView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = .clear
        view.borderWidth = 2
        view.borderColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var cancellables: Set<AnyCancellable> = Set()

    private var viewModel: DrawerEffectCellCollectionViewModel?

    private lazy var imageViewTopConstraint: NSLayoutConstraint = imageView.topAnchor.constraint(equalTo: contentView.topAnchor)
    private lazy var imageViewLeadingConstraint: NSLayoutConstraint = imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
    private lazy var imageViewTrailingConstraint: NSLayoutConstraint = imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
    private lazy var imageViewBottomConstraint: NSLayoutConstraint = imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        viewModel?.cancelImageLoad()
        viewModel = nil
        cancellables.removeAll()
        cancellables = Set()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        shadowView.layer.cornerRadius = shadowView.bounds.height / 2
    }

    public override func set(withViewModel viewModel: DrawerEffectCellCollectionViewModel) {
        cancellables = Set()
        self.viewModel = viewModel

        imageView.contentMode = viewModel.imageContentMode
        imageView.image = viewModel.image
        imageViewTopConstraint.constant = viewModel.imageInsets.top
        imageViewLeadingConstraint.constant = viewModel.imageInsets.left
        imageViewTrailingConstraint.constant = -viewModel.imageInsets.right
        imageViewBottomConstraint.constant = -viewModel.imageInsets.bottom
        selectedBorderView.isHidden = !viewModel.isSelected
        if viewModel.isLoading {
            loadingIndicator.startAnimating()
            shadowView.isHidden = false
        } else {
            loadingIndicator.stopAnimating()
            shadowView.isHidden = true
        }

        viewModel.imagePublisher
            .receive(on: DispatchQueue.main)
            .sink (receiveCompletion: { _ in }, receiveValue: { [weak self] image in
                guard let self = self else { return }
                self.imageView.image = image
            }).store(in: &cancellables)

        viewModel.isSelectedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSelected in
                guard let self = self else { return }
                self.selectedBorderView.isHidden = !isSelected
            }.store(in: &cancellables)

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                if isLoading {
                    self.loadingIndicator.startAnimating()
                    self.shadowView.isHidden = false
                } else {
                    self.loadingIndicator.stopAnimating()
                    self.shadowView.isHidden = true
                }
            }.store(in: &cancellables)
        viewModel.accessibilityLabelPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] label in
                guard let self = self else { return }
                self.accessibilityLabel = label
            }.store(in: &cancellables)
    }

    private func setUpView() {
        isAccessibilityElement = true

        contentView.backgroundColor = InterfaceCommonColors.drawerBlack.color
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        contentView.addSubview(imageView)
        contentView.addSubview(shadowView)
        contentView.addSubview(loadingIndicator)
        contentView.addSubview(selectedBorderView)

        NSLayoutConstraint.activate([
            imageViewTopConstraint,
            imageViewLeadingConstraint,
            imageViewTrailingConstraint,
            imageViewBottomConstraint,

            selectedBorderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectedBorderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectedBorderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            selectedBorderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            shadowView.topAnchor.constraint(equalTo: loadingIndicator.topAnchor, constant: -2),
            shadowView.leadingAnchor.constraint(equalTo: loadingIndicator.leadingAnchor, constant: -2),
            shadowView.trailingAnchor.constraint(equalTo: loadingIndicator.trailingAnchor, constant: 2),
            shadowView.bottomAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 2),
        ])
    }
}
