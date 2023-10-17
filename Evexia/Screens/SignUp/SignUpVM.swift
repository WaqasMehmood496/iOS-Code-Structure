//
//  SignUpVM.swift
//  Evexia
//
//  Created by  Artem Klimov on 30.06.2021.
//

import Foundation
import Combine

class SignUpVM: SignUpVMType {
    
    // MARK: - Properties
    @Published var isAcceptedTerms = false
    
    private let repository: SignUpRepositoryProtocol
    private var router: SignUpNavigation
    private var cancellables: [AnyCancellable] = []
    private var userEmail: String = ""
    private var password: String = ""

    init(router: SignUpNavigation, repository: SignUpRepositoryProtocol) {
        self.router = router
        self.repository = repository
    }
    
    func transform(input: SignUpVMInput) -> SignUpVMOuput {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        input.subscribeOnVerificationToken
            .sink(receiveValue: { [weak self] in
                self?.repository.subscribeOnVerificationToken()
            }).store(in: &cancellables)
        
        input.unsubscribeOnVerificationToken
            .sink(receiveValue: { [weak self] in
                self?.repository.unsubscribeOnVerificationToken()
            }).store(in: &cancellables)
        
        let emailValidationOutput: SignUpVMOuput = input.emailValidation.map { email -> SignUpVCState in
            if email.isEmpty {
                return .emailValidation(.normal)
            }
            return email.isValidEmail ? .emailValidation(.valid) : .emailValidation(.error)
        }.eraseToAnyPublisher()
        
        let loading: SignUpVMOuput = input.signUp.map { _ in .loading }
            .eraseToAnyPublisher()
        
        let registration = self.registrationPublisher(for: input.signUp)
        
        let passwordValidationOutput: SignUpVMOuput = input.passwordValidation.map { password -> SignUpVCState in
            if password.isEmpty {
                return .passwordValidation(.normal)
            }
            return password.isValidPassword ? .passwordValidation(.valid) : .passwordValidation(.error)
        }.eraseToAnyPublisher()
        
        let loginAvailable = Publishers.CombineLatest3(emailValidationOutput, passwordValidationOutput, $isAcceptedTerms)
            .map({ email, password, isAcceptedTerms -> SignUpVCState in
                let isValidCredentials = email == .emailValidation(.valid) && password == .passwordValidation(.valid) && isAcceptedTerms
                return .signUpAvailable(isValidCredentials)
            }).eraseToAnyPublisher()
        
        let dismissSocialWebView = input.dismissSocialWebView
            .map({ [weak self] state -> SignUpVCState in
                self?.repository.refreshFCMTokenRequest()
                return .dismissSocialWebView(state)
            }).eraseToAnyPublisher()
        
        let verify = repository.verification
                .receive(on: DispatchQueue.main)
                .map({ result -> SignUpVCState in
                    switch result {
                    case let .failure(serverError):
                        return .failure(serverError)
                    case .success:
                        self.router.navigateToOnboarding()
                        return .success
                    }
                }).eraseToAnyPublisher()
        
        return Publishers.Merge7(passwordValidationOutput, emailValidationOutput, loading, registration, loginAvailable, dismissSocialWebView, verify).eraseToAnyPublisher()
    }
    
    private func registrationPublisher(for signUp: AnyPublisher<(String, String), Never>) -> SignUpVMOuput {
        return signUp.flatMap { [unowned self] userCredentials -> AnyPublisher<Result<BaseResponse, Error>, Never> in
            self.userEmail = userCredentials.1
            return self.repository.signUp(with: userCredentials.1, and: userCredentials.0)
        }
        .receive(on: DispatchQueue.main)
        .map { [unowned self] result -> SignUpVCState in
            switch result {
            case let .failure(error):
                let serverError = error as? ServerError ?? ServerError(errorCode: .networkError)
                return .failure(serverError)
            case .success:
                self.router.navigateToVerification(for: self.userEmail)
                return .success
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Navigation
    func navigateToSignIn() {
        self.router.navigateToSignIn()
    }
    
    func navigateToAgreements(type: Agreements) {
        self.router.navigateToAgreements(type: type)
    }
    
    func showVCAfterCloseSocialWebView(state: Int?) {
        state != nil ? router.showRoot() : router.showOnboarding()
    }
    
    func showAppleSignIn(dismissSocialWebView: PassthroughSubject<Int?, Never>) {
        self.router.showAppleSignIn(dismissSocialWebView: dismissSocialWebView)
    }
    
    func showGoogleSignIn(dismissSocialWebView: PassthroughSubject<Int?, Never>) {
        self.router.showGoogleSignIn(dismissSocialWebView: dismissSocialWebView)
    }
}
