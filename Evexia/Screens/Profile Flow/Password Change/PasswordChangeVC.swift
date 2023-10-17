//
//  PasswordChangeVC.swift
//  Evexia
//
//  Created by  Artem Klimov on 16.08.2021.
//

import Foundation
import UIKit
import Combine

final class PasswordChangeVC: BaseViewController, StoryboardIdentifiable {
    
    @IBOutlet private weak var currentPasswordStack: UIStackView!
    @IBOutlet private weak var newPasswordStack: UIStackView!
    @IBOutlet private weak var confirmPasswordStack: UIStackView!
    @IBOutlet private weak var previousPasswordField: PasswordTextField!
    @IBOutlet private weak var newPasswordField: PasswordTextField!

    @IBOutlet private weak var confirmPasswordField: PasswordTextField!
    @IBOutlet private weak var newPasswordErrorLabel: UILabel!
    @IBOutlet private weak var forgotPasswordButton: UIButton!
    @IBOutlet private weak var currentPasswordErrorLabel: UILabel!
    @IBOutlet private weak var updatePasswordButton: RequestButton!
    @IBOutlet private weak var confirmPasswordErrorLabel: UILabel!
    
    // MARK: - Properties
    internal var viewModel: PasswordChangeVMType!
    
    private let appear = PassthroughSubject<Void, Never>()
    private let newPasswordValidation = PassthroughSubject<String, Never>()
    private let confirmPasswordValidation = PassthroughSubject<String, Never>()
    private let previousPasswordValidation = PassthroughSubject<String, Never>()
    private let matchValidation = PassthroughSubject<Bool, Never>()
    private let updatePassword = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.bind(to: self.viewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.appear.send()
        (self.tabBarController as? TabBarController)?.setTabBarHidden(true, animated: true)

    }
}

// MARK: - Private Methods
private extension PasswordChangeVC {
    func setupUI() {
        self.localizeStrings()
        self.setupTextFields()
    }
    
    func localizeStrings() {
        self.newPasswordField.placeholder = "Set new password".localized()
        self.currentPasswordErrorLabel.text = "The password doesn’t match.".localized()
        self.confirmPasswordErrorLabel.text = "Both passwords must match".localized()
        self.confirmPasswordField.placeholder = "Confirm password".localized()
        self.updatePasswordButton.setTitle("Save changes".localized(), for: .normal)
        self.newPasswordErrorLabel.text = "Your password must contain at least 1 lower case, 1 upper case character, 1 special symbol, 1 number, min length - 8, only Latin symbols".localized()
        self.forgotPasswordButton.setTitle("Forgot password?".localized(), for: .normal)
        self.title = "Password change".localized()
    }
    
    func setupTextFields() {
        self.previousPasswordField.delegate = self
        self.newPasswordField.delegate = self
        self.confirmPasswordField.delegate = self
    }
    
    func bind(to viewModel: PasswordChangeVMType) {
        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()
        
        let input = PasswordChangeVMInput(appear: appear.eraseToAnyPublisher(),
                                          newPasswordValidation: newPasswordValidation.eraseToAnyPublisher(),
                                          confirmPasswordValidation: confirmPasswordValidation.eraseToAnyPublisher(),
                                          updatePassword: updatePassword.eraseToAnyPublisher(),
                                          previousPasswordValidation: previousPasswordValidation.eraseToAnyPublisher())
        
        let output = viewModel.transform(input: input)
        
        output.sink(receiveValue: { [unowned self] state in
            self.render(state)
        }).store(in: &cancellables)
        
    }
    
    func render(_ state: PasswordChangeVCState) {
        switch state {
        case .idle:
            break
        case .loading:
            self.updatePasswordButton.isRequestAction.send(true)
            
        case let .newPasswordValidation(state):
            if !newPasswordField.isFirstResponder {
                UIView.animate(withDuration: 0.3, animations: {
                    self.newPasswordField.setState(for: state)
                    self.newPasswordErrorLabel.textColor = state == .error ? .error : .gray900
                })
            }
        case let .confirmPasswordValidation(confirmState):
            if !confirmPasswordField.isFirstResponder {
                UIView.animate(withDuration: 0.3, animations: {
                    self.confirmPasswordField.setState(for: confirmState.fieldState)
                    self.confirmPasswordErrorLabel.alpha = confirmState != .notMatch ? 0.0 : 1.0
                    self.confirmPasswordErrorLabel.isHidden = confirmState != .notMatch

                    self.confirmPasswordStack.layoutIfNeeded()
                })
            }
        case let .failure(error):
            if error.errorCode == .passwordNotMatch {
                UIView.animate(withDuration: 0.3, animations: {
                    self.currentPasswordErrorLabel.isHidden = false
                    self.currentPasswordErrorLabel.alpha = 1.0
                    self.currentPasswordStack.setNeedsLayout()
                    self.currentPasswordStack.layoutIfNeeded()
                })
            }
            self.modalAlert(modalStyle: error.errorCode)
            
            self.confirmPasswordField.setState(for: .error)
            self.newPasswordField.setState(for: .error)
            self.updatePasswordButton.isRequestAction.send(false)
            Log.error(error)
        case .success:
            self.modalAlert(modalStyle: ModalAlertViewStyles.passwordUpdated, completion: { [weak self] in
                self?.viewModel.closeView()
            })
            
            self.updatePasswordButton.isRequestAction.send(false)
        case let .passwordUpdate(isAvailabel):
            self.updatePasswordButton.isEnabled = isAvailabel
        case let .previousPasswordValidation(state):
            if !previousPasswordField.isFirstResponder {
                self.previousPasswordField.setState(for: state)
            }
        }
    }
    
    func validateInputText(for textField: UITextField) {
        switch textField {
        case self.newPasswordField:
            self.newPasswordValidation.send(textField.text ?? "")
        case self.confirmPasswordField:
            self.confirmPasswordValidation.send(textField.text ?? "")
        case self.previousPasswordField:
            self.previousPasswordValidation.send(textField.text ?? "")
        default:
            break
        }
    }
}

// MARK: - Actions
extension PasswordChangeVC {

    @IBAction func updateButtonDidTap(_ sender: RequestButton) {
        self.updatePassword.send()
        self.view.endEditing(true)
    }
    
    @IBAction func forgotPasswordButtonDidTap(_ sender: UIButton) {
        self.viewModel.navigateToSetPassword()
    }
}

// MARK: - UITextFieldDelegate
extension PasswordChangeVC: UITextFieldDelegate {
    
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
