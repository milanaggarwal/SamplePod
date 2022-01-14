import UIKit
import AVFoundation
import CameraCommon
import Combine

/// The default implementation of the `LayerStack` protocol.
public final class DefaultLayerStack: TransformLayerStack {
    
    /// Publishes events that happen in the coordinator
    public var layerEventPublisher: AnyPublisher<TransformLayerStackEvent, Never> {
        _layerEventPublisher
            .eraseToAnyPublisher()
    }
    private lazy var _layerEventPublisher = PassthroughSubject<TransformLayerStackEvent, Never>()
    
    /// Storage for the layers.
    private(set) public var layers: [TransformLayer] = []
    
    /// Create a new instance of `DefaultLayerStack`.
    ///
    public init() {
        // Nothing, yet.
    }
    
    /// Check whether or not the layers array contains the specified layer.
    ///
    /// - Parameter layer: The layer to check for membership.
    /// - Returns: `true` if the layer was found, otherwise `false`
    ///
    private func contains(_ layer: TransformLayer) -> Bool {
        layers.contains { $0.id == layer.id }
    }
    
    /// Sort the layers array.
    ///
    private func sort() {
        layers.sort { $0.shouldRemainAtBottom || $0.zIndex < $1.zIndex }
    }
    
    /// Find the minimum index among all layers.
    ///
    private var minIndex: Int {
        layers.map { $0.zIndex }.min() ?? 0
    }
    
    /// Find the maximum index among all layers.
    private var maxIndex: Int {
        layers.map { $0.zIndex }.max() ?? 0
    }
    
// MARK: - Protocol Conformance
    
    public func add(_ layer: TransformLayer) {
        guard !contains(layer) else { return }
        _layerEventPublisher.send(.willAdd(layer))
        if layer.shouldRemainAtBottom {
            layer.zIndex = minIndex
            layers.insert(layer, at: 0)
        } else {
            layer.zIndex = maxIndex + 1
            layers.append(layer)
        }
        sort()
        _layerEventPublisher.send(.didAdd(layer))
    }
    
    public func remove(_ layer: TransformLayer) {
        _layerEventPublisher.send(.willRemove(layer))
        layers = layers.filter { $0.id != layer.id }
        _layerEventPublisher.send(.didRemove(layer))
    }
    
    public func canMoveBackward(_ layer: TransformLayer) -> Bool {
        if let layerIndex = layers.firstIndex(where: { $0.id == layer.id }), layerIndex > 0 {
            let lowerLayer = layers[layerIndex - 1]
            return !lowerLayer.shouldRemainAtBottom
        } else {
            return false
        }
    }
    
    public func canMoveForward(_ layer: TransformLayer) -> Bool {
        return contains(layer) && layer.id != layers.last?.id && !layer.shouldRemainAtBottom
    }
    
    public func moveBackward(_ layer: TransformLayer) {
        guard
            canMoveBackward(layer),
            let layerIndex = layers.firstIndex(where: { $0.id == layer.id })
        else { return }
        let otherLayer = layers[layerIndex - 1]
        swap(layer, with: otherLayer)
    }
    
    public func moveForward(_ layer: TransformLayer) {
        guard
            canMoveForward(layer),
            let layerIndex = layers.firstIndex(where: { $0.id == layer.id })
        else { return }
        let otherLayer = layers[layerIndex + 1]
        swap(layer, with: otherLayer)
    }
    
    public func moveToBack(_ layer: TransformLayer) {
        guard canMoveBackward(layer) else { return }
        layer.zIndex = minIndex - 1
        sort()
    }
    
    public func moveToFront(_ layer: TransformLayer) {
        guard canMoveForward(layer) else { return }
        layer.zIndex = maxIndex + 1
        sort()
    }
    
    public func swap(_ layer: TransformLayer, with otherLayer: TransformLayer) {
        let zIndex = layer.zIndex
        layer.zIndex = otherLayer.zIndex
        otherLayer.zIndex = zIndex
        sort()
    }
    
    public func findLayer(byId id: UUID) -> TransformLayer? {
        layers.first(where: { $0.id == id })
    }
    
    public func update(withSize size: CGSize, orientation: Orientation, time: CMTime, features: [String : Any]) {
        let id = Logger.shared.startPerformanceTrace(label: "transform-stack-update-layers")
        layers.forEach { layer in
            if layer.shouldRemoveLayer {
                layer.prepareForRemoval()
            } else {
                layer.update(withSize: size, orientation: orientation, time: time, features: features)
            }
        }
        layers = layers.filter { !$0.shouldRemoveLayer }
        Logger.shared.endPerformanceTrace(id: id)
    }
    
    public func render(withInput input: CIImage) -> CIImage {
        let id = Logger.shared.startPerformanceTrace(label: "transform-stack-render-layers")
        let result = layers.reduce(input) { input, layer in
            let result = layer.render(withInput: input) ?? input
            Logger.shared.logPerformanceEvent(label: layer.debugName)
            return result
        }
        Logger.shared.endPerformanceTrace(id: id)
        return result
    }
    
    public func testSelection(withPoint point: CGPoint, inRect rect: CGRect) -> TransformLayer? {
        layers.last(where: { $0.shouldBecomeSelected(fromTap: point, inRect: rect) })
    }
}
