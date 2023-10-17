//
//  PasswordRecoveryVMType.swift
//  Evexia
//
//  Created by  Artem Klimov on 04.07.2021.
//

import Combine

typealias PasswordRecoveryVMOuput = AnyPublisher<PasswordRecoveryVCState, Never>

protocol PasswordRecoveryVMType {
    func navigateToSetPassword()
    func transform(input: PasswordRecoveryVMInput) -> PasswordRecoveryVMOuput
}

struct PasswordRecoveryVMInput {
    /// triggered when the email has been entered
    let emailValidation: AnyPublisher<String, Never>
    /// triggered when the  recovery button  did tap
    let recoverPassword: AnyPublisher<String, Never>
}

enum PasswordRecoveryVCState {
    case loading
    case emailValidation(TextFieldState)
    case failure(ServerError)
    case success
    case recoveryAvailable(Bool)
}

extension PasswordRecoveryVCState: Equatable {
    static func == (lhs: PasswordRecoveryVCState, rhs: PasswordRecoveryVCState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading): return true
        case (.success, .success): return true
        case (.failure, .failure): return true
        case let (.emailValidation(a), .emailValidation(b)): return a == b
        default: return false
        }
    }
}
