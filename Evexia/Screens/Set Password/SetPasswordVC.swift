//
//  SetPasswordVC.swift
//  Evexia
//
//  Created by  Artem Klimov on 06.07.2021.
//

import Combine
import UIKit
import Atributika

class SetPasswordVC: BaseViewController, StoryboardIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var newPasswordTextField: PasswordTextField!
    @IBOutlet private weak var confirmPasswordTextField: PasswordTextField!
    @IBOutlet private weak var updatePasswordButton: RequestButton!
    @IBOutlet private weak var fieldsStackView: UIStackView!
    @IBOutlet private weak var passwordErrorLabel: UILabel!
    @IBOutlet private weak var confirmPasswordErrorLabel: UILabel!
    
    // MARK: - Properties
    internal var viewModel: SetPasswordVMType!
    
    private let appear = PassthroughSubject<Void, Never>()
    private let newPasswordValidation = PassthroughSubject<String, Never>()
    private let confirmPasswordValidation = PassthroughSubject<String, Never>()
    private let updatePassword = PassthroughSubject<String, Never>()
    private var cancellables: [AnyCancellable] = []
    
    private var paragraphStyle: NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5
        paragraphStyle.alignment = .center
        return paragraphStyle
    }
    
    var descriptionStyle: Style {
        return Style()
            .foregroundColor(.gray400, .normal)
            .font(UIFont(name: "NunitoSans-Regular", size: 16.0)!)
            .custom(self.paragraphStyle, forAttributedKey: NSAttributedString.Key.paragraphStyle)
    }
    
    // MARK: - VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        Log.info(Configuration().environment)
        self.setupUI()
        self.bind(to: self.viewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.tabBarController as? TabBarController)?.setTabBarHidden(true, animated: false)
        self.appear.send()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        (self.tabBarController as? TabBarController)?.setTabBarHidden(false, animated: false)
    }

}
// MARK: - Private Methods
private extension SetPasswordVC {
    func setupUI() {
        self.localizeStrings()
        self.setupTextFields()
    }
    
    func localizeStrings() {
        self.titleLabel.text = "Create new password".localized()
        self.descriptionLabel.attributedText = "Your new password must be different from previous used password".localized().style(tags: descriptionStyle).attributedString
        self.newPasswordTextField.placeholder = "Set password".localized()
        self.confirmPasswordTextField.placeholder = "Confirm password".localized()
        self.updatePasswordButton.setTitle("Update Password".localized(), for: .normal)
        self.passwordErrorLabel.text = "Your password must contain at least 1 lower case, 1 upper case character, 1 special symbol, 1 number, min length - 8, only Latin symbols".localized()
    }
    
    func setupTextFields() {
        self.newPasswordTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
    }
    
    func bind(to viewModel: SetPasswordVMType) {
        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()
        
        let input = SetPasswordVMInput(appear: appear.eraseToAnyPublisher(),
                                       newPasswordValidation: newPasswordValidation.eraseToAnyPublisher(),
                                       confirmPasswordValidation: confirmPasswordValidation.eraseToAnyPublisher(),
                                       updatePassword: updatePassword.eraseToAnyPublisher())
        
        let output = viewModel.transform(input: input)
        
        output.sink(receiveValue: { [unowned self] state in
            self.render(state)
        }).store(in: &cancellables)
        
    }
    
    func render(_ state: SetPasswordVCState) {
        switch state {
        case .idle:
            break
        case .loading:
            self.updatePasswordButton.isRequestAction.send(true)
        case let .newPasswordValidation(state):
            if !newPasswordTextField.isFirstResponder {
                UIView.animate(withDuration: 0.3, animations: {
                    self.newPasswordTextField.setState(for: state)
                    switch state {
                    case .valid:
                        self.passwordErrorLabel.isHidden = true
                        self.passwordErrorLabel.textColor = .blue84
                        self.passwordErrorLabel.alpha = 0.0
                    case .error:
                        self.passwordErrorLabel.isHidden = false
                        self.passwordErrorLabel.textColor = .error
                        self.passwordErrorLabel.alpha = 1.0
                    case .normal, .editing, .active:
                        self.passwordErrorLabel.isHidden = false
                        self.passwordErrorLabel.textColor = .blue84
                        self.passwordErrorLabel.alpha = 1.0
                    }
                    self.fieldsStackView.layoutIfNeeded()
                    
                })
            }
        case let .confirmPasswordValidation(confirmState):
            if !confirmPasswordTextField.isFirstResponder {
                UIView.animate(withDuration: 0.3, animations: {
                    self.confirmPasswordTextField.setState(for: confirmState.fieldState)
                    self.confirmPasswordErrorLabel.text = confirmState.text
                    self.confirmPasswordErrorLabel.fadeTransition(0.2)
                    self.confirmPasswordErrorLabel.isHidden = confirmState.fieldState != .error
                    self.confirmPasswordErrorLabel.alpha = confirmState.fieldState != .error ? 0.0 : 1.0
                    self.fieldsStackView.layoutIfNeeded()
                })
            }
        case let .failure(error):
            self.modalAlert(modalStyle: error.errorCode)
            self.confirmPasswordTextField.setState(for: .error)
            self.newPasswordTextField.setState(for: .error)
            self.updatePasswordButton.isRequestAction.send(false)
            Log.error(error)
        case .success:
            self.updatePasswordButton.isRequestAction.send(false)
            self.showSuccessAlert()
            return
        case let .passwordUpdate(isAvailabel):
            self.updatePasswordButton.isEnabled = isAvailabel
        }
    }
    
    func validateInputText(for textField: UITextField) {
        switch textField {
        case self.newPasswordTextField:
            self.newPasswordValidation.send(textField.text ?? "")
        case self.confirmPasswordTextField:
            self.confirmPasswordValidation.send(textField.text ?? "")
        default:
            break
        }
    }
    
    func showSuccessAlert() {
        self.modalAlert(modalStyle: ModalAlertViewStyles.passwordSet, completion: { [weak self] in
            self?.viewModel.applyNavigation()
        })
    }
}

// MARK: - Actions
extension SetPasswordVC {
    
    @IBAction func setPasswordButtonDidTap(_ sender: RequestButton) {
        self.updatePassword.send(self.newPasswordTextField.text ?? "")
        self.newPasswordTextField.resignFirstResponder()
        self.confirmPasswordTextField.resignFirstResponder()
    }
    
}

// MARK: - UITextFieldDelegate
extension SetPasswordVC: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.validateInputText(for: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.validateInputText(for: textField)
        textField.resignFirstResponder()
        textField.layoutIfNeeded()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let field = textField as? BaseTextField else { return }
        field.setState(for: .editing)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.contains(" ") {
            return false
        }
        return true
    }
}
