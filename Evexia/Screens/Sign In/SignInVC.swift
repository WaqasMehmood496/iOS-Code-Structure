//
//  SignInVC.swift
//  Evexia
//
//  Created by Yura Yatseyko on 23.06.2021.
//

import UIKit
import Combine

class SignInVC: BaseViewController, StoryboardIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var fieldsStackView: UIStackView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var socialLoginLabel: UILabel!
    @IBOutlet private weak var emailErrorLabel: UILabel!
    @IBOutlet private weak var passwordErrorLabel: UILabel!
    @IBOutlet private weak var notRegisteredLabel: UILabel!
    
    @IBOutlet private weak var emailTextField: EmailTextField!
    @IBOutlet private weak var passwordTextField: PasswordTextField!
    
    @IBOutlet private weak var forgotPasswordButton: UIButton!
    @IBOutlet private weak var loginButton: RequestButton!
    @IBOutlet private weak var googleLoginButton: UIButton!
    @IBOutlet private weak var appleLoginButton: UIButton!
    @IBOutlet private weak var signUpButton: UIButton!
    
    // MARK: - Properties
    var viewModel: SignInVMType!
    
    private var cancellables: [AnyCancellable] = []
    private let appear = PassthroughSubject<Void, Never>()
    private let emailValidation = PassthroughSubject<String, Never>()
    private let passwordValidation = PassthroughSubject<String, Never>()
    private let signIn = PassthroughSubject<(String, String), Never>()
    private let dismissSocialWebView = PassthroughSubject<Int?, Never>()
    private let subscribeOnToken = PassthroughSubject<Void, Never>()
    private let unsubscribeOnToken = PassthroughSubject<Void, Never>()
    
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
        self.appear.send()
        self.subscribeOnToken.send()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeOnToken.send()
    }
}

// MARK: - Private Methods
private extension SignInVC {
    func setupUI() {
        self.setupLabels()
        self.setupButtons()
        self.setupTextFields()
    }
    
    func setupLabels() {
        self.titleLabel.text = "Welcome back".localized() + " 👋"
        self.socialLoginLabel.text = "or log in with".localized()
        self.notRegisteredLabel.text = "Not registered yet?".localized()
        self.passwordErrorLabel.text = "Your password must contain at least 1 lower case, 1 upper case character, 1 special symbol, 1 number, min length - 8, only Latin symbols".localized()
        self.emailErrorLabel.text = "Invalid email address, please try again".localized()
    }
    
    func setupTextFields() {
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
        self.emailTextField.textContentType = .username
        self.passwordTextField.textContentType = .password
    }
    
    func setupButtons() {
        self.forgotPasswordButton.setTitle("Forgot password?".localized(), for: .normal)
        self.loginButton.setTitle("Log in".localized(), for: .normal)
        self.signUpButton.setTitle("Sign up".localized(), for: .normal)
    }
    
    func bind(to viewModel: SignInVMType) {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        let input = SignInVMInput(appear: appear.eraseToAnyPublisher(),
                                  emailValidation: emailValidation.eraseToAnyPublisher(),
                                  passwordValidation: passwordValidation.eraseToAnyPublisher(),
                                  signIn: signIn.eraseToAnyPublisher(),
                                  dismissSocialWebView: dismissSocialWebView.eraseToAnyPublisher(),
                                  subscribeOnVerificationToken: subscribeOnToken.eraseToAnyPublisher(),
                                  unsubscribeOnVerificationToken: unsubscribeOnToken.eraseToAnyPublisher())
        
        let output = viewModel.transform(input: input)
        
        output.sink(receiveValue: { [unowned self] state in
            self.render(state)
        }).store(in: &cancellables)
    }
    
    func render(_ state: SignInVCState) {
        switch state {
        case .idle:
            break
        case let .dismissSocialWebView(state):
            viewModel.showVCAfterCloseSocialWebView(state: state)
        case .loading:
            self.loginButton.isRequestAction.send(true)
        case let .passwordValidation(state):
            if !passwordTextField.isFirstResponder {
                self.passwordErrorLabel.text = "Your password must contain at least 1 lower case, 1 upper case character, 1 special symbol, 1 number, min length - 8, only Latin symbols".localized()
                
                let shouldHide = state != .error
                UIView.animate(withDuration: 0.3, animations: {
                    self.passwordTextField.setState(for: state)
                    if self.passwordErrorLabel.isHidden != shouldHide {
                        self.passwordErrorLabel.isHidden = shouldHide
                        self.passwordErrorLabel.alpha = shouldHide ? 0.0 : 1.0
                    }
                    self.fieldsStackView.layoutIfNeeded()
                })
            }
        case let .emailValidation(state):
            
            let shouldHide = state != .error
            self.emailErrorLabel.text = "Invalid email address, please try again".localized()
            if !emailTextField.isFirstResponder {
                UIView.animate(withDuration: 0.3, animations: {
                    self.emailTextField.setState(for: state)
                    if self.emailErrorLabel.isHidden != shouldHide {
                        self.emailErrorLabel.isHidden = shouldHide
                        self.emailErrorLabel.alpha = shouldHide ? 0.0 : 1.0
                    }
                    self.fieldsStackView.layoutIfNeeded()
                })
            }
        case let .failure(error):
            switch error.errorCode {
            case .notValidCredentials:
                UIView.animate(withDuration: 0.3, animations: {
                    self.loginButton.isEnabled = false
                    self.emailTextField.setState(for: .error)
                    self.passwordTextField.setState(for: .error)
                    self.emailErrorLabel.text = "The email address doesn’t match any account".localized()
                    self.passwordErrorLabel.text = "The password doesn’t match. Try again?".localized()
                    self.emailErrorLabel.isHidden = false
                    self.emailErrorLabel.alpha = 1.0
                    self.passwordErrorLabel.isHidden = false
                    self.passwordErrorLabel.alpha = 1.0
                    self.view.layoutIfNeeded()
                })
            default:
                self.modalAlert(modalStyle: error.errorCode)
            }
            self.loginButton.isRequestAction.send(false)
        case .success:
            self.loginButton.isRequestAction.send(false)
        case let .loginAvailable(value):
            self.loginButton.isEnabled = value
        }
    }
    
    func validateInputText(for textField: UITextField) {
        switch textField {
        case self.emailTextField:
            self.emailValidation.send(textField.text ?? "")
        case self.passwordTextField:
            self.passwordValidation.send(textField.text ?? "")
        default:
            break
        }
    }
}

// MARK: - Actions
extension SignInVC {
    @IBAction func signInButtonDidTap(_ sender: Any) {
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.signIn.send((self.passwordTextField.text ?? "", self.emailTextField.text ?? ""))
    }
    
    @IBAction func signIUpButtonDidTap(_ sender: Any) {
        self.viewModel.navigateToSignUp()
    }
    
    @IBAction func forgotPasswordButtonDidTap(_ sender: Any) {
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.viewModel.navigateToPasswordRecovery()
    }
    
    @IBAction func googleLoginButtonDidTap(_ sender: Any) {
        viewModel.showGoogleSignIn(dismissSocialWebView: dismissSocialWebView)
    }
    
    @IBAction func appleLoginButtonDidTap(_ sender: Any) {
        viewModel.showAppleSignIn(dismissSocialWebView: dismissSocialWebView)
    }
}

// MARK: - UITextFieldDelegate
extension SignInVC: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.validateInputText(for: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.validateInputText(for: textField)
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
        switch textField {
        case self.passwordTextField:
            if string.contains(" ") {
                return false
            }
            return true
        default:
            return true
        }
    }
}
