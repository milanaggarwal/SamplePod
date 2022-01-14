import Combine
import UIKit

/// Defines a type that provide the data interface for the `DrawerView`
public protocol DrawerViewModel {
    /// The title to be display in the title label
    var title: String? { get }
    var titleStringPublisher: AnyPublisher<String?, Never> { get }
    /// The accessibility label for the title button
    var titleButtonAccessibilityLabel: String? { get }
    var titleButtonAccessibilityLabelPublisher: AnyPublisher<String?, Never> { get }
    /// Whether or not the back button should be visible
    var showsBackButton: Bool { get }
    var showsBackButtonPublisher: AnyPublisher<Bool, Never> { get }
    /// Whether or not the close button should be visible
    var showsCloseButton: Bool { get }
    var showsCloseButtonPublisher: AnyPublisher<Bool, Never> { get }
    /// The content view that should be displayed in the drawer
    var contentView: UIView { get }
    var contentViewPublisher: AnyPublisher<UIView, Never> { get }
    /// An element in the view that will be focused for VoiceOver when the drawer is opened or content is changed
    var elementToFocusWhenPresenting: UIView? { get }
    /// Returns the contents desired width
    var preferredWidth: CGFloat? { get }
    var preferredWidthPublisher: AnyPublisher<CGFloat?, Never> { get }
    /// The height of the content that is displayed in the content view
    var contentHeight: CGFloat? { get }
    var contentHeightPublisher: AnyPublisher<CGFloat?, Never> { get }
    /// Calculates the views preferred height for given width
    func preferredHeight(forWidth width: CGFloat) -> CGFloat
    /// Called when the user taps the title button
    func titleButtonTapped()
    /// Called when the user taps the close button
    func closeButtonTapped()
}

