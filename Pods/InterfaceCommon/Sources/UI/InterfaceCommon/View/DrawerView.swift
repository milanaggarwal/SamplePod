import Combine
import UIKit

/// The delegate defines the methods implemented when the drawer is dragged using gesture
public protocol DrawerDragViewDelegate: AnyObject {

    /// The method defines the operations that are to be done after the drawer hides when dragged down
    func drawerViewWillHide()
}

/// View that is used to display child content with a drawer style
public final class DrawerView: UIView {
    
    private let viewModel: DrawerViewModel

    /// The currently child content view
    private var currentContentView: UIView?

    public private(set) weak var dragDelegate: DrawerDragViewDelegate?

    private static let dragIndicatorSize = CGSize(width: 50, height: 5)
    private static let insets = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
    private var initialOrigin: CGPoint = .zero

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    }()
    
    private lazy var dragIndicatorView: UIView = {
        let dragIndicatorView = UIView()
        dragIndicatorView.backgroundColor = UIColor.white
        dragIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        dragIndicatorView.layer.cornerRadius = 2.5
        return dragIndicatorView
    }()

    private lazy var titleButton: UIButton = {
        let titleButton = UIButton()
        titleButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        titleButton.titleLabel?.adjustsFontForContentSizeCategory = true
        titleButton.setTitleColor(.white, for: .normal)
        titleButton.translatesAutoresizingMaskIntoConstraints = false
        titleButton.addTarget(self, action: #selector(titleButtonTapped), for: .touchUpInside)
        titleButton.setContentCompressionResistancePriority(.required, for: .vertical)
        return titleButton
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(CommonAssets.downChevron.image, for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.accessibilityLabel = InterfaceStrings.Drawer.close
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    /// View for containing all the views in the drawer so they can be dragged
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 10
        view.backgroundColor = InterfaceCommonColors.drawerBackground.color
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var contentContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var preferredWidthConstraint: NSLayoutConstraint = {
        let constraint = widthAnchor.constraint(equalToConstant: 375)
        constraint.priority = .almostRequired
        constraint.isActive = true
        return constraint
    }()
    
    private lazy var preferredHeightConstraint: NSLayoutConstraint = {
        let constraint = contentContainerView.heightAnchor.constraint(equalToConstant: 375)
        constraint.priority = .almostRequired
        constraint.isActive = true
        return constraint
    }()
    
    private lazy var cancellables = Set<AnyCancellable>()
    
    private var preferredWidthCancellable: AnyCancellable?
    private var updatedContentHeightCancellable: AnyCancellable?
    
    ///  Create the view for the drawer.
    ///
    /// - Parameters:
    ///     - viewModel: View model confirming to the protocol DrawerViewModel for showing the content in the drawer
    ///     - dragDelegate: Used to show the drawer handle to be able to drag it. If passed while initialising the DrawerView, it makes the drawer draggable, else not.
    ///
    public init(viewModel: DrawerViewModel, dragDelegate: DrawerDragViewDelegate?) {
        self.viewModel = viewModel
        self.dragDelegate = dragDelegate
        super.init(frame: .zero)
        setUpView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpSubscriptions() {
        #warning("Connect to all the publishers")
        viewModel.contentViewPublisher
            .filter {[weak self] in $0 !==  self?.currentContentView }
            .sink {[weak self] contentView in
                guard let self = self else { return }
                self.set(contentView: contentView)
            }.store(in: &cancellables)
        
        viewModel.preferredWidthPublisher.sink {[weak self] contentPreferredWidth in
            guard let self = self else { return }
            if let width = contentPreferredWidth {
                self.preferredWidthConstraint.constant = width
                self.preferredWidthConstraint.isActive = true
            } else {
                self.preferredWidthConstraint.isActive = false
            }
        }.store(in: &cancellables)
        
        viewModel.contentHeightPublisher.sink {[weak self] contentHeight in
            guard let self = self else { return }
            if let height = contentHeight{
                self.preferredHeightConstraint.constant = height
                self.preferredHeightConstraint.isActive = true
            } else {
                self.preferredHeightConstraint.isActive = false
            }
            UIView.animate(withDuration: 0.33) {
                self.superview?.layoutIfNeeded()
            }
        }.store(in: &cancellables)
        
        viewModel.titleStringPublisher
            .sink {[weak self] title in
            guard let self = self else { return }
            self.titleButton.setTitle(title, for: .normal)
        }.store(in: &cancellables)
        
        viewModel.titleButtonAccessibilityLabelPublisher
            .sink {[weak self] titleAccessibilityLabel in
            guard let self = self else { return }
            self.titleButton.accessibilityLabel = titleAccessibilityLabel
            }.store(in: &cancellables)
        
        viewModel.showsBackButtonPublisher
            .sink {[weak self] showsBackButton in
            guard let self = self else { return }
            if showsBackButton {
                self.titleButton.setImage(CommonAssets.circleBack.image, for: .normal)
                self.titleButton.setPadding(contentPadding: .zero,
                                            imageTitlePadding: 2)
                self.titleButton.accessibilityTraits = .button
            } else {
                self.titleButton.setImage(nil, for: .normal)
                self.titleButton.setPadding(contentPadding: .zero,
                                            imageTitlePadding: 0)
                self.titleButton.accessibilityTraits = .header
            }
            }.store(in: &cancellables)
        
        viewModel.showsCloseButtonPublisher.sink {[weak self] showCloseButton in
            guard let self = self else { return }
            self.closeButton.isHidden = !showCloseButton
        }.store(in: &cancellables)
    }
    
    /// Sets the given view as the content view. Removes the current content view if there is one
    /// - Parameter contentView: The content view to be set
    private func set(contentView: UIView) {
        if let currentContentView = currentContentView {
            currentContentView.removeFromSuperview()
        }
        currentContentView = contentView
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),
        ])
    }
    
    private func setUpView() {
        addSubview(containerView)
        containerView.addSubview(titleButton)
        containerView.addSubview(closeButton)
        containerView.addSubview(contentContainerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            titleButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            closeButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
        
            contentContainerView.topAnchor.constraint(equalTo: titleButton.bottomAnchor, constant: 8),
            contentContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        if((dragDelegate) != nil) {
            containerView.addSubview(dragIndicatorView)
            addGestureRecognizer(panGestureRecognizer)
            NSLayoutConstraint.activate([
                dragIndicatorView.widthAnchor.constraint(equalToConstant: Self.dragIndicatorSize.width),
                dragIndicatorView.heightAnchor.constraint(equalToConstant: Self.dragIndicatorSize.height),
                dragIndicatorView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                dragIndicatorView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Self.insets.top),
            ])
        }
        setUpSubscriptions()
    }
    
    //MARK: - Actions
    
    @objc
    private func titleButtonTapped() {
        viewModel.titleButtonTapped()
    }
    
    @objc
    private func closeButtonTapped() {
        viewModel.closeButtonTapped()
    }

    @objc
    private func handlePan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
            case .began:
                initialOrigin = containerView.frame.origin
            case .changed:
                let translation = sender.translation(in: sender.view)
                containerView.frame.origin = CGPoint(x: containerView.frame.origin.x,
                                               y: max(initialOrigin.y, initialOrigin.y + translation.y))
            case .ended,
                .cancelled:
                let currentOffset = containerView.frame.origin.y
                if (currentOffset - initialOrigin.y) < (containerView.bounds.height / 2) {
                    UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                        self.containerView.frame.origin = self.initialOrigin
                    }) { _ in }
                } else {
                    // Use the delegate method to hide the drawer and update the bottom bar
                    self.dragDelegate?.drawerViewWillHide()
                    UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                        self.containerView.frame.origin.y = self.bounds.height
                    }) { _ in
                        /* The following is done to ensure that when "Options / Effects / etc" is tapped again, it sets the containerView frame back to its initial origin for it to become visible again */
                        self.containerView.frame.origin.y = self.initialOrigin.y
                    }
                }
            default:
                break
        }
    }

    public struct Height {
        let landscapeHeight: CGFloat
        let portraitHeight: CGFloat
        
        public init(landscapeHeight: CGFloat, portraitHeight: CGFloat) {
            self.landscapeHeight = landscapeHeight
            self.portraitHeight = portraitHeight
        }

        public var current: CGFloat {
            UIApplication.shared.orientation.isPortrait ? portraitHeight : landscapeHeight
        }
    }
}
