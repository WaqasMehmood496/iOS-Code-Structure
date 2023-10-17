//
//  SignInVMType.swift
//  Evexia
//
//  Created by Yura Yatseyko on 23.06.2021.
//

import Combine

typealias SignInVMOuput = AnyPublisher<SignInVCState, Never>

protocol SignInVMType {
    func transform(input: SignInVMInput) -> SignInVMOuput
    func navigateToSignUp()
    func navigateToPasswordRecovery()
    func showAppleSignIn(dismissSocialWebView: PassthroughSubject<Int?, Never>)
    func showGoogleSignIn(dismissSocialWebView: PassthroughSubject<Int?, Never>)
    func showVCAfterCloseSocialWebView(state: Int?)
}

struct SignInVMInput {
    /// called when a screen becomes visible
    let appear: AnyPublisher<Void, Never>
    /// triggered when the email has been entered
    let emailValidation: AnyPublisher<String, Never>
    /// triggered when the password has been entered
    let passwordValidation: AnyPublisher<String, Never>
    /// triggered when the sign in button did tap
    let signIn: AnyPublisher<(String, String), Never>
    /// triggered when social webView is closed
    let dismissSocialWebView: AnyPublisher<Int?, Never>
    ///
    let subscribeOnVerificationToken: AnyPublisher<Void, Never>
    ///
    let unsubscribeOnVerificationToken: AnyPublisher<Void, Never>
}

enum SignInVCState {
    case idle
    case loading
    case emailValidation(TextFieldState)
    case passwordValidation(TextFieldState)
    case failure(ServerError)
    case success
    case loginAvailable(Bool)
    case dismissSocialWebView(Int?)
}

extension SignInVCState: Equatable {
    static func == (lhs: SignInVCState, rhs: SignInVCState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.loading, .loading): return true
        case (.success, .success): return true
        case (.failure, .failure): return true
        case let (.emailValidation(a), .emailValidation(b)): return a == b
        case let (.passwordValidation(a), .passwordValidation(b)): return a == b
        default: return false
        }
    }
}
