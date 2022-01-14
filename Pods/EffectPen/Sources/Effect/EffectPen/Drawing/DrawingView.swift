import UIKit
import InterfaceCommon

class DrawingView: UIView {
    
    /// Delegate
    private var viewModel: DrawingViewModel?
    
    /// Views
    private let actionView: UIView? = nil
    private let colorPickerView: ColorPickerView
    public var isDrawing: Bool {
        return viewModel?.isDrawing == true
    }
    
    public init(frame: CGRect, delegate: DrawingViewDelegate?) {
        colorPickerView = ColorPickerView(style: .vertical, delegate: delegate, includeRainbowButton: (delegate?.isRainbowActive ?? false))
        super.init(frame: frame)
        
        viewModel = DrawingViewModel(view: self, delegate: delegate)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        addSubview(colorPickerView)

        colorPickerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorPickerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 60),
            colorPickerView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -16),
            colorPickerView.widthAnchor.constraint(equalToConstant: 40),
            colorPickerView.heightAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    public func updateBrushSize(recognizer: UIPinchGestureRecognizer) {
        // Make sure this pinch gesture wasn't initiated inside the color picker and we are not already drawing.
        guard !colorPickerView.frame.contains(recognizer.location(in: self)) && viewModel?.isDrawing == false else { return }
        
        // Update the preview and scale the brush size.
        viewModel?.updateBrushSize(recognizer: recognizer)
    }
    
    public func touch(recognizer: UIGestureRecognizer) {
        if colorPickerView.frame.contains(recognizer.location(in: self)) && viewModel?.isDrawing == false {
            return
        }

        viewModel?.handleTouch(recognizer: recognizer)
    }
}
