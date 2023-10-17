//
//  SignInVM.swift
//  Evexia
//
//  Created by Yura Yatseyko on 23.06.2021.
//

import UIKit
import Combine

final class SignInVM: SignInVMType {
    
    // MARK: - Properties
    private let repository: SignInRepositoryProtocol
    private var router: SignInNavigation
    private var cancellables: [AnyCancellable] = []
    
    init(router: SignInNavigation, repository: SignInRepositoryProtocol) {
        self.router = router
        self.repository = repository
        
    }
    
    func transform(input: SignInVMInput) -> SignInVMOuput {
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
        
        let emailValidationOutput: SignInVMOuput = input.emailValidation.map { email -> SignInVCState in
            if email.isEmpty {
                return .emailValidation(.normal)
            }
            return email.isValidEmail ? .emailValidation(.valid) : .emailValidation(.error)
        }.eraseToAnyPublisher()
        
        let loading: SignInVMOuput = input.signIn.map { _ in .loading }
                                  .eraseToAnyPublisher()
        
        let authenticate = self.authenticationPublisher(for: input.signIn)
           
        let passwordValidationOutput: SignInVMOuput = input.passwordValidation.map { password -> SignInVCState in
            if password.isEmpty {
                return .passwordValidation(.normal)
            }
            return password.isValidPassword ? .passwordValidation(.valid) : .passwordValidation(.error)
        }.eraseToAnyPublisher()
        
        let loginAvailable = Publishers.CombineLatest(emailValidationOutput, passwordValidationOutput)
            .map({ email, password -> SignInVCState in
                let isValidLogin = email == .emailValidation(.valid) && password == .passwordValidation(.valid)
                return .loginAvailable(isValidLogin)
            }).eraseToAnyPublisher()
        
        let dismissSocialWebView = input.dismissSocialWebView
            .map({ [weak self] state -> SignInVCState in
                //self?.repository.refreshFCMTokenRequest()
                return .dismissSocialWebView(state)
            }).eraseToAnyPublisher()
        
        let verify = repository.verification
                .receive(on: DispatchQueue.main)
                .map({ result -> SignInVCState in
                    switch result {
                    case let .failure(serverError):
                        return .failure(serverError)
                    case .success:
                        self.router.navigateToOnboarding()
                        return .success
                    }
                }).eraseToAnyPublisher()
        
        return Publishers.Merge7(passwordValidationOutput, emailValidationOutput, loading, authenticate, loginAvailable, dismissSocialWebView, verify).eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    private func authenticationPublisher(for signIn: AnyPublisher<(String, String), Never>) -> SignInVMOuput {
        var authEmail: String = ""

        return signIn.flatMap({ [unowned self] password, email -> AnyPublisher<Result<User, Error>, Never> in
            authEmail = email
            return self.repository.signIn(with: email, and: password)
        })
        .receive(on: DispatchQueue.main)
        .map({ [weak self] result -> SignInVCState in
            switch result {
            case let .failure(error):
                let serverError = error as? ServerError ?? ServerError(errorCode: .networkError)
                if serverError.errorCode == .notVerifyedUser {
                    UserDefaults.isSignUpInProgress = true
                    UserDefaults.email = authEmail
                }
                return .failure(serverError)
            case let .success(user):
                if user.firstName.isEmpty {
                    UserDefaults.isOnboardingDone = false
                    self?.router.navigateToOnboarding()
                } else {
                    self?.router.navigateToRoot()
                }
                return .success
            }
        }).eraseToAnyPublisher()
    }
    
    // MARK: - Navigation
    func navigateToSignUp() {
        self.router.navigateToSignUp()
    }
    
    func navigateToPasswordRecovery() {
        self.router.navigateToPasswordRecovery()
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
