//
//  SignUpVMType.swift
//  Evexia
//
//  Created by  Artem Klimov on 30.06.2021.
//

import Combine

typealias SignUpVMOuput = AnyPublisher<SignUpVCState, Never>

protocol SignUpVMType {
    func transform(input: SignUpVMInput) -> SignUpVMOuput
    func navigateToSignIn()
    func navigateToAgreements(type: Agreements)
    func showAppleSignIn(dismissSocialWebView: PassthroughSubject<Int?, Never>)
    func showGoogleSignIn(dismissSocialWebView: PassthroughSubject<Int?, Never>)
    func showVCAfterCloseSocialWebView(state: Int?)

    var isAcceptedTerms: Bool { get set }
}

struct SignUpVMInput {
    /// called when a screen becomes visible
    let appear: AnyPublisher<Void, Never>
    /// triggered when the email has been entered
    let emailValidation: AnyPublisher<String, Never>
    /// triggered when the password has been entered
    let passwordValidation: AnyPublisher<String, Never>
    /// triggered when the sign in button did tap
    let signUp: AnyPublisher<(String, String), Never>
    /// triggered when social webView is closed
    let dismissSocialWebView: AnyPublisher<Int?, Never>
    ///
    let subscribeOnVerificationToken: AnyPublisher<Void, Never>
    ///
    let unsubscribeOnVerificationToken: AnyPublisher<Void, Never>
}

enum SignUpVCState {
    case idle
    case loading
    case emailValidation(TextFieldState)
    case passwordValidation(TextFieldState)
    case failure(ServerError)
    case success
    case signUpAvailable(Bool)
    case dismissSocialWebView(Int?)
}

extension SignUpVCState: Equatable {
    static func == (lhs: SignUpVCState, rhs: SignUpVCState) -> Bool {
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
