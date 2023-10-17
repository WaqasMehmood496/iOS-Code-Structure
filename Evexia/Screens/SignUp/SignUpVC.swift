//
//  SignUpVC.swift
//  Evexia
//
//  Created by  Artem Klimov on 30.06.2021.
//

import Combine
import UIKit
import Atributika

class SignUpVC: BaseViewController, StoryboardIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var fieldsStackView: UIStackView!
    @IBOutlet private weak var termsLabel: AttributedLabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var socialSignUpLabel: UILabel!
    @IBOutlet private weak var alreadyRegisterLabel: UILabel!
    
    @IBOutlet private weak var emailTextField: EmailTextField!
    @IBOutlet private weak var passwordTextField: PasswordTextField!
    
    @IBOutlet private weak var emailErrorLabel: UILabel!
    @IBOutlet private weak var passwordErrorLabel: UILabel!
    @IBOutlet private weak var signUpButton: RequestButton!
    @IBOutlet private weak var googleSignUpButton: UIButton!
    @IBOutlet private weak var appleSignUpButton: UIButton!
    @IBOutlet private weak var signInButton: UIButton!
    @IBOutlet private weak var termsCheckbox: Checkbox!
    
    // MARK: - Properties
    internal var viewModel: SignUpVMType!
        
    private let appear = PassthroughSubject<Void, Never>()
    private let emailValidation = PassthroughSubject<String, Never>()
    private let passwordValidation = PassthroughSubject<String, Never>()
    private let signUp = PassthroughSubject<(String, String), Never>()
    private let dismissSocialWebView = PassthroughSubject<Int?, Never>()
    private let subscribeOnToken = PassthroughSubject<Void, Never>()
    private let unsubscribeOnToken = PassthroughSubject<Void, Never>()
    private var cancellables: [AnyCancellable] = []
    
    private var termsAttributes: Style {
        return Style("terms")
            .foregroundColor(.blue, .normal)
            .foregroundColor(.blue, .highlighted)
            .font(UIFont(name: "Outfit-SemiBold", size: 16.0)!)
    }
    
    private var privacyAttributes: Style {
        return Style("privacy")
            .foregroundColor(.blue, .normal)
            .foregroundColor(.blue, .highlighted)
            .font(UIFont(name: "Outfit-SemiBold", size: 16.0)!)
    }
    
    private var plainAttributes: Style {
        return Style
            .foregroundColor(.blue84, .normal)
            .font(UIFont(name: "Outfit-Light", size: 16.0)!)
        
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
        self.appear.send()
        self.subscribeOnToken.send()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeOnToken.send()
    }
}
// MARK: - Private Methods
private extension SignUpVC {
    func setupUI() {
        self.setupTermsView()
        self.setupLabels()
        self.setupButtons()
        self.setupTextFields()
    }
    
    func setupLabels() {
        self.titleLabel.text = "Create account".localized()
        self.socialSignUpLabel.text = "or sign up with".localized()
        self.alreadyRegisterLabel.text = "Already registered?".localized()
        self.passwordErrorLabel.text = "Your password must contain: at least 1 lower case, 1 upper case character, 1 special symbol, 1 number, min length - 8, only Latin symbols".localized()
        self.emailErrorLabel.text = "Invalid email address, please try again"
        
        self.termsLabel.attributedText = "I agree to the <terms>Terms</terms> and <privacy>Privacy Policy</privacy>.".style(tags: [self.termsAttributes, self.privacyAttributes]).styleAll(self.plainAttributes)
    }
    
    func setupTermsView() {
        self.termsLabel.numberOfLines = 0
        self.termsLabel.onClick = { [weak self] _, detection in
            self?.click(detection: detection)
        }
    }
    
    func setupTextFields() {
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    func setupButtons() {
        self.signInButton.setTitle("Log in".localized(), for: .normal)
        self.signUpButton.setTitle("Sign up".localized(), for: .normal)
    }
    
    func bind(to viewModel: SignUpVMType) {
        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()
        
        let input = SignUpVMInput(appear: appear.eraseToAnyPublisher(),
                                  emailValidation: emailValidation.eraseToAnyPublisher(),
                                  passwordValidation: passwordValidation.eraseToAnyPublisher(),
                                  signUp: signUp.eraseToAnyPublisher(),
                                  dismissSocialWebView: dismissSocialWebView.eraseToAnyPublisher(),
                                  subscribeOnVerificationToken: subscribeOnToken.eraseToAnyPublisher(),
                                  unsubscribeOnVerificationToken: unsubscribeOnToken.eraseToAnyPublisher())
        
        let output = viewModel.transform(input: input)
        
        output.sink(receiveValue: { [unowned self] state in
            self.render(state)
        }).store(in: &cancellables)
        
        self.termsCheckbox.isSelectedPublisher
            .assign(to: \.self.viewModel.isAcceptedTerms, on: self)
            .store(in: &cancellables)
    }
    
    func render(_ state: SignUpVCState) {
        switch state {
        case .idle:
            break
        case let .dismissSocialWebView(state):
            viewModel.showVCAfterCloseSocialWebView(state: state)
        case .loading:
            self.signUpButton.isRequestAction.send(true)
        case let .passwordValidation(state):
            self.passwordErrorLabel.text = "Your password must contain: at least 1 lower case, 1 upper case character, 1 special symbol, 1 number, min length - 8, only Latin symbols".localized()
            if !passwordTextField.isFirstResponder {
                UIView.animate(withDuration: 0.3, animations: {
                    self.passwordTextField.setState(for: state)
                    self.passwordErrorLabel.textColor = state != .error ? .blue84 : .error
                    self.fieldsStackView.layoutIfNeeded()
                })
            }
        case let .emailValidation(state):
            self.emailErrorLabel.text = "Invalid email address, please try again"
            if !emailTextField.isFirstResponder {
                UIView.animate(withDuration: 0.3, animations: {
                    self.emailTextField.setState(for: state)
                    self.emailErrorLabel.isHidden = state != .error
                    self.emailErrorLabel.alpha = state != .error ? 0.0 : 1.0
                    self.fieldsStackView.layoutIfNeeded()
                })
            }
        case let .failure(error):
            switch error.errorCode {
            case .emailAlreadyTaken:
                self.emailErrorLabel.text = "This email address is already taken".localized()
                UIView.animate(withDuration: 0.3, animations: {
                    self.emailTextField.setState(for: .error)
                    self.signUpButton.isEnabled = false
                    if self.emailErrorLabel.isHidden {
                        self.emailErrorLabel.alpha = 1.0
                        self.emailErrorLabel.isHidden = false
                    }
                    self.fieldsStackView.layoutIfNeeded()
                })
            default:
                modalAlert(modalStyle: error.errorCode)
            }
            self.signUpButton.isRequestAction.send(false)
            Log.error(error)
        case .success:
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
            self.termsCheckbox.selected()
            self.signUpButton.isRequestAction.send(false)
        case let .signUpAvailable(isAvailable):
            self.signUpButton.isEnabled = isAvailable
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
    
    func click(detection: Detection) {
        switch detection.type {
        case let .tag(tag):
            if tag.name == "terms" {
                self.viewModel.navigateToAgreements(type: .termsOfUse)
            } else {
                self.viewModel.navigateToAgreements(type: .privacyPolicy)
            }
        default:
            break
        }
    }
}

// MARK: - Actions
extension SignUpVC {
    
    @IBAction func signUpButtonDidTap(_ sender: RequestButton) {
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.signUp.send((self.passwordTextField.text ?? "", self.emailTextField.text ?? ""))
    }
    
    @IBAction func googleSignUpButtonDidTap(_ sender: UIButton) {
        viewModel.showGoogleSignIn(dismissSocialWebView: dismissSocialWebView)
    }
    
    @IBAction func appleSignUpButtonDidTap(_ sender: UIButton) {
        viewModel.showAppleSignIn(dismissSocialWebView: dismissSocialWebView)
    }
    
    @IBAction func signInButtonDidTap(_ sender: UIButton) {
        self.viewModel.navigateToSignIn()
    }
    
}

// MARK: - UITextFieldDelegate
extension SignUpVC: UITextFieldDelegate {
    
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
