import UIKit
import SwiftUI
import CameraCommon
import CameraTransform
import Combine

/// Base implementation for an ideal effect sources provider
///
public protocol EffectSourcesHandler : AnyObject {
    var pickerDelegate: GalleryPickerDelegate? { get set }
    var effectSourcesChangedPublisher: AnyPublisher<[EffectSource], Never> { get }
    func getEffectSources(layerCoordinator: EffectLayerCoordinator) -> [EffectSource]
}

/// Coordinator that manages the UI gestures for the Camera Flow
///
public final class EffectLayerCoordinator: NSObject {
    
    private let tapGestureName = "camera.effectLayerCoordinator.tapGesture"
    
    public weak var parentView: UIView? {
        didSet {
            if let view = parentView {
                setupGestureRecognizers(view: view)
            }
        }
    }
    
    public private(set) var activeTransformLayer: TransformLayer?
    
    private let effectService: EffectService
    private let transformController: TransformController
    private let effectSourceHandler: EffectSourcesHandler
    
    private lazy var cancellables: Set<AnyCancellable> = Set()
    
    public init(effectService: EffectService, transformController: TransformController, effectSourceHandler: EffectSourcesHandler) {
        self.transformController = transformController
        self.effectService = effectService
        self.effectSourceHandler = effectSourceHandler
        
        super.init()
        
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        transformController.layerStack.layerEventPublisher.sink { [weak self] layerEvent in
            guard let self = self else { return }
            switch layerEvent {
            case let .willAdd(layer):
                self.willAdd(layer: layer)
            case let .didAdd(layer):
                self.onLayerAdded(layer: layer)
            case let .willRemove(layer), let .didRemove(layer):
                if self.activeTransformLayer?.id.uuidString == layer.id.uuidString {
                    self.resetActiveTransformLayer()
                }
            }
        }.store(in: &cancellables)
        
        transformController.processorStack.layerEventPublisher.sink { [weak self] processorEvent in
            guard let self = self else { return }
            switch processorEvent {
            case let .willAdd(layer):
                self.willAdd(processor: layer)
            case .didAdd(_), .willRemove(_), .didRemove(_):
                return
            }
        }.store(in: &cancellables)
        
        self.effectSourceHandler.effectSourcesChangedPublisher.sink(receiveValue: { [weak self] sources in
            self?.effectService.addOrUpdate(sources: sources)
        }).store(in: &cancellables)
    }
    
    private func willAdd(processor: BufferProcessor) {
        if let layer = processor as? GesturedLayer, let view = self.parentView {
            layer.setGestureDelegate(uiGestureRecognizerDelegate: self, previewView: view)
        }
    }
    
    private func willAdd(layer: TransformLayer) {
        self.resetActiveTransformLayer()
        if let layer = layer as? GesturedLayer, let view = self.parentView {
            layer.setGestureDelegate(uiGestureRecognizerDelegate: self, previewView: view)
        }
    }
    
    private func onLayerAdded(layer: TransformLayer) {
        self.activeTransformLayer = layer
        if let layer = self.activeTransformLayer as? TransformationalLayer {
            layer.actionDelegate = self
            layer.coordinateConverter = CoordinateConverter(videoSize: VideoResolution.halfHD.portraitSize, videoFrame: self.parentView?.bounds ?? CGRect.zero, screenScale: UIScreen.main.scale)
        }
        if let subView = layer.getConfigurationInterface() {
            self.parentView?.addSubview(subView)
        }
        if let layer = layer as? HasSubViews {
            for subView in layer.subViews() {
                self.parentView?.addSubview(subView)
            }
            layer.updateConstraints()
        }
        
        if let layer = self.activeTransformLayer as? EditableLayer {
            layer.startEditing()
        } else if let selectableLayer = self.activeTransformLayer as? SelectableLayer {
            selectableLayer.select()
        }
    }
    
    private func resetActiveTransformLayer() {
        if let selectableLayer = self.activeTransformLayer as? SelectableLayer {
            selectableLayer.deselect()
        }
        activeTransformLayer = nil
    }
    
    private func setupGestureRecognizers(view: UIView) {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tapRecognizer.name = tapGestureName
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)

        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinched))
        pinchRecognizer.delegate = self
        view.addGestureRecognizer(pinchRecognizer)

        let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotated))
        rotationRecognizer.delegate = self
        view.addGestureRecognizer(rotationRecognizer)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panned))
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.maximumNumberOfTouches = 1
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
    }
}

/// Handle gestures and pass them to the layers
///
extension EffectLayerCoordinator: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        true
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let view = self.parentView, let recogniser = gestureRecognizer as? UITapGestureRecognizer {
            let point = recogniser.location(in: view)
            let shouldBegin = transformController.layerStack.testSelection(withPoint: point, inRect: view.frame) != nil
            if shouldBegin {
                return recogniser.name == tapGestureName
            }
        }
        return true
    }
    
    @objc
    private func pinched(recognizer: UIPinchGestureRecognizer) {
        guard let view = self.parentView else { return }
        let point = recognizer.location(in: view)
        if let activeLayer = activeTransformLayer, !activeLayer.shouldBecomeSelected(fromTap: point, inRect: view.frame) {
            resetActiveTransformLayer()
        }
        if activeTransformLayer == nil {
            activeTransformLayer = transformController.layerStack.testSelection(withPoint: point, inRect: view.frame)
            if let selectableLayer = self.activeTransformLayer as? SelectableLayer {
                selectableLayer.select()
            }
        }
        if let scalableLayer = self.activeTransformLayer as? ScalableLayer {
            scalableLayer.scale(withPinchRecognizer: recognizer, view: view)
        }
    }

    @objc
    private func rotated(recognizer: UIRotationGestureRecognizer) {
        guard let view = self.parentView else { return }
        let point = recognizer.location(in: view)
        if let activeLayer = activeTransformLayer, !activeLayer.shouldBecomeSelected(fromTap: point, inRect: view.frame) {
            resetActiveTransformLayer()
        }
        if activeTransformLayer == nil {
            activeTransformLayer = transformController.layerStack.testSelection(withPoint: point, inRect: view.frame)
            if let selectableLayer = self.activeTransformLayer as? SelectableLayer {
                selectableLayer.select()
            }
        }
        if let rotatableLayer = self.activeTransformLayer as? RotatableLayer {
            rotatableLayer.rotate(withRotationRecognizer: recognizer)
        }
    }

    @objc
    private func panned(recognizer: UIPanGestureRecognizer) {
        guard let view = self.parentView else { return }
        let point = recognizer.location(in: view)
        if let activeLayer = activeTransformLayer, !activeLayer.shouldBecomeSelected(fromTap: point, inRect: view.frame) {
            resetActiveTransformLayer()
        }
        if activeTransformLayer == nil {
            activeTransformLayer = transformController.layerStack.testSelection(withPoint: point, inRect: view.frame)
            if let selectableLayer = self.activeTransformLayer as? SelectableLayer {
                selectableLayer.select()
            }
        }
        
        if let movableLayer = self.activeTransformLayer as? MovableLayer {
            movableLayer.move(withPanRecognizer: recognizer, view: view)
        }
    }
    
    @objc
    private func tapped(recognizer: UIPanGestureRecognizer) {
        guard let view = self.parentView else { return }
        let point = recognizer.location(in: view)
        if let tappedOnActiveLayer = self.activeTransformLayer?.shouldBecomeSelected(fromTap: point, inRect: view.frame), tappedOnActiveLayer, let editableLayer = self.activeTransformLayer as? EditableLayer {
            editableLayer.startEditing()
        } else {
            // deselect curent active layer
            if let selectableLayer = self.activeTransformLayer as? SelectableLayer {
                selectableLayer.deselect()
            }
            
            activeTransformLayer = transformController.layerStack.testSelection(withPoint: point, inRect: view.frame)
            // if activeLayer is nil pass this to top layer
            
            // select new active layer
            if let selectableLayer = self.activeTransformLayer as? SelectableLayer {
                selectableLayer.select()
            }
        }
    }
}

/// Handle layer actions
///
extension EffectLayerCoordinator : ActionEventDelegate {
    public func duplicate(layer: TransformLayer) {
        guard let copyableLayer = layer as? NSCopying, let newLayer = copyableLayer.copy() as? TransformLayer else { return }
        transformController.layerStack.add(newLayer)
    }
    
    public func move(layer: TransformLayer, directionisUp: Bool) {
        if directionisUp {
            transformController.layerStack.moveForward(layer)
        } else {
            transformController.layerStack.moveBackward(layer)
        }
    }
    
    public func delete(layer: TransformLayer) {
        layer.shouldRemoveLayer = true
        resetActiveTransformLayer()
    }
}

