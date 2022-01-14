import Combine
import UIKit

/// A view that contains a text filed and cancel button that is used as a search field
final class SearchBarView: UIView {
    /// The current value of the search field
    var searchTerm: String? {
        textField.text
    }
    
    /// Publisher that fires whenever the search term is updated
    var searchTermPublisher: AnyPublisher<String?, Never> {
        searchTermSubject
            .handleEvents(receiveOutput: {[weak self] searchTerm in
                guard let self = self else { return }
                let shouldHideCancelButton = searchTerm == nil || searchTerm?.isEmpty == true
                self.setCancelButton(hidden: shouldHideCancelButton, animated: true)
            })
            .eraseToAnyPublisher()
    }
    
    private lazy var searchTermSubject: PassthroughSubject<String?, Never> = PassthroughSubject()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var textField: InsetTextField = {
        let textField = InsetTextField()
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 8
        textField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        return textField
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(InterfaceStrings.Common.cancel, for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        setUpView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(cancelButton)
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func setCancelButton(hidden: Bool, animated: Bool) {
        guard cancelButton.isHidden != hidden else { return }
        
        guard animated else {
            cancelButton.isHidden = hidden
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            self.cancelButton.isHidden = hidden
            self.stackView.layoutIfNeeded()
        }
    }
    
    @objc
    private func textChanged(_ sender: Any) {
        searchTermSubject.send(textField.text)
    }
    
    @objc
    private func cancelButtonTapped(_ sender: Any) {
        textField.text = nil
        searchTermSubject.send(nil)
        textField.endEditing(true)
    }
    
}

