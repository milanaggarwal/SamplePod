import Combine
import Foundation
import UIKit
import CameraCommon

/// View model used in the drawer collection view cell. It defines various publishers used to show the image, loading and selected state on UI.
final class DefaultDrawerEffectCellCollectionViewModel<Item: SearchableCollectionViewItem>: DrawerEffectCellCollectionViewModel {

    var image: UIImage?
    var item: Item

    var imagePublisher: AnyPublisher<UIImage, Error>

    var imageContentMode: UIView.ContentMode {
        _imageContentModePublisher.value
    }

    var imageContentModePublisher: AnyPublisher<UIView.ContentMode, Never> {
        _imageContentModePublisher
            .eraseToAnyPublisher()
    }

    var imageInsets: UIEdgeInsets {
        _imageInsetsPublisher.value
    }

    var imageInsetsPublisher: AnyPublisher<UIEdgeInsets, Never> {
        _imageInsetsPublisher
            .eraseToAnyPublisher()
    }

    var isLoading: Bool {
        return _isImageLoadingPublisher.value
    }

    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        _isImageLoadingPublisher
            .eraseToAnyPublisher()
    }

    var isSelected: Bool {
        _isSelectedPublisher.value
    }

    var isSelectedPublisher: AnyPublisher<Bool, Never> {
        _isSelectedPublisher
            .eraseToAnyPublisher()
    }

    var accessibilityLabel: String {
        _accessibilityLabelPublisher.value
    }

    var accessibilityLabelPublisher: AnyPublisher<String, Never> {
        _accessibilityLabelPublisher
            .eraseToAnyPublisher()
    }

    private let accessibilityPosition: Int

    private var imageLoadingCancellable: AnyCancellable?
    private lazy var cancellables: Set<AnyCancellable> = Set()

    private lazy var _imageContentModePublisher: CurrentValueSubject<UIView.ContentMode, Never> = CurrentValueSubject(.scaleAspectFill)
    private lazy var _imageInsetsPublisher: CurrentValueSubject<UIEdgeInsets, Never> = CurrentValueSubject(.zero)
    private lazy var _isSelectedPublisher: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    private lazy var _isImageLoadingPublisher: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    private lazy var _accessibilityLabelPublisher: CurrentValueSubject<String, Never> = CurrentValueSubject("")

    init(item: Item, accessibilityPosition: Int) {
        self.item = item
        self.accessibilityPosition = accessibilityPosition
        switch item.displayMode {
            case let .imageOnly(imagePublisher):
                self.imagePublisher = imagePublisher
        }
        _accessibilityLabelPublisher.value = item.accessibilityLabel ?? ""
        _isImageLoadingPublisher.value = getLoadingValue(state: item.state)
        _isSelectedPublisher.value = item.isSelected
        _imageInsetsPublisher.value = item.shouldHaveImageInset ? UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12): .zero
        _imageContentModePublisher.value = item.shouldHaveContentModeFit ? .scaleAspectFit : .scaleAspectFill
        loadImageIfNecessary()
        setUpSubscriptions(item: item)
    }

    func cancelImageLoad() {
        imageLoadingCancellable?.cancel()
    }

    private func getLoadingValue(state: SearchableCollectionViewItemState) -> Bool {
        switch(state) {
        case .noEffect, .appliedEffect:
            return false
        case .applyingEffect:
            return true
        }
    }

    private func setUpSubscriptions(item: Item) {
        item.statePublisher
            .sink { [weak self] state in
                guard let self = self else { return }
                self._isImageLoadingPublisher.value = self.getLoadingValue(state: state)
            }.store(in: &cancellables)
        item.isSelectedPublisher
            .sink { [weak self] isSelected in
                guard let self = self else { return }
                self._isSelectedPublisher.value = isSelected
            }.store(in: &cancellables)
            
    }

    private func loadImageIfNecessary() {
        _isImageLoadingPublisher.value = true
        imageLoadingCancellable = self.imagePublisher
            .sink(receiveCompletion: {_ in }, receiveValue: { [weak self] image in
                guard let self = self else { return }
                self.image = image
                self._isImageLoadingPublisher.value = false })
    }
}


