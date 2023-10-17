//
//  PasswordRecoveryVC.swift
//  Evexia
//
//  Created by  Artem Klimov on 02.07.2021.
//

import UIKit
import Combine

class PasswordRecoveryVC: BaseViewController, StoryboardIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var contentStackView: UIStackView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var decriptionLabel: UILabel!
    @IBOutlet private weak var emailErrorLabel: UILabel!
    @IBOutlet private weak var emailTextField: EmailTextField!
    @IBOutlet private weak var sendEmailButton: RequestButton!
    
    // MARK: - Properties
    var viewModel: PasswordRecoveryVMType!
    
    private let emailValidation = PassthroughSubject<String, Never>()
    private let recoverPassword = PassthroughSubject<String, Never>()
    private var cancellables: [AnyCancellable] = []

    // MARK: - VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        Log.info(Configuration().environment)
        
        self.setupUI()
        self.bind(to: self.viewModel)
    }
}

// MARK: - Private Methods
private extension PasswordRecoveryVC {
    func setupUI() {
        self.localizeStrings()
        self.setupFields()
    }
    
    func localizeStrings() {
        self.titleLabel.text = "Password recovery".localized()
        self.decriptionLabel.text = "Don’t worry, happens to the best of us.".localized()
        self.emailTextField.placeholder = "Email".localized()
        self.sendEmailButton.setTitle("Email me a recovery link".localized(), for: .normal)
        self.emailErrorLabel.text = "Invalid email address, please try again".localized()
    }
    
    func setupFields() {
        self.emailTextField.delegate = self
    }
    
    func bind(to viewModel: PasswordRecoveryVMType) {
        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()
        
        let input = PasswordRecoveryVMInput(emailValidation: self.emailValidation.eraseToAnyPublisher(),
                                            recoverPassword: self.recoverPassword.eraseToAnyPublisher())
        
        let output = viewModel.transform(input: input)
        
        output
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] state in
                self.render(state)
            }).store(in: &cancellables)
    }
    
    func render(_ state: PasswordRecoveryVCState) {
        switch state {
        case .loading:
            self.sendEmailButton.isRequestAction.send(true)
        case let .emailValidation(state):
            if !emailTextField.isFirstResponder {
                self.emailErrorLabel.text = "Invalid email address, please try again".localized()
                UIView.animate(withDuration: 0.3, animations: {
                    self.emailTextField.setState(for: state)
                    self.emailErrorLabel.isHidden = state != .error
                    self.emailErrorLabel.alpha = state != .error ? 0.0 : 1.0
                    self.stackView.spacing = state != .error ? 24.0 : 16.0
                    self.stackView.layoutIfNeeded()
                })
            }
        case let .failure(error):
            self.sendEmailButton.isEnabled = false
            self.sendEmailButton.isRequestAction.send(false)
            switch error.errorCode {
            case .emailNotMatch:
                self.emailErrorLabel.text = "The email address doesn’t match any account".localized()
                UIView.animate(withDuration: 0.3, animations: {
                    self.emailTextField.setState(for: .error)
                    self.emailErrorLabel.isHidden = false
                    self.emailErrorLabel.alpha = 1.0
                    self.stackView.spacing = 16.0
                    self.stackView.layoutIfNeeded()
                })
            default:
                self.modalAlert(modalStyle: error.errorCode)
            }
        case .success:
            self.sendEmailButton.isRequestAction.send(false)
        case let .recoveryAvailable(isAvailable):
            self.sendEmailButton.isEnabled = isAvailable
        }
    }
}

// MARK: - Actions
extension PasswordRecoveryVC {
    @IBAction func sendLinkButtonDidTap(_ sender: RequestButton) {
        self.emailTextField.resignFirstResponder()
        self.recoverPassword.send(self.emailTextField.text ?? "")
    }
}

// MARK: - UITextFieldDelegate
extension PasswordRecoveryVC: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.emailValidation.send(textField.text ?? "")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.emailValidation.send(textField.text ?? "")
        if textField.text != ""{
            self.sendEmailButton.layer.borderColor = UIColor.orange.cgColor
            self.sendEmailButton.layer.borderWidth = 1.0
        }
        textField.resignFirstResponder()
        textField.layoutIfNeeded()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let field = textField as? BaseTextField else { return }
        field.setState(for: .active)
        self.sendEmailButton.layer.borderColor = UIColor.clear.cgColor
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
