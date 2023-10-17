//
//  PasswordChangeVMType.swift
//  Evexia
//
//  Created by  Artem Klimov on 17.08.2021.
//

import Foundation
import Combine

typealias PasswordChangeVMOuput = AnyPublisher<PasswordChangeVCState, Never>

protocol PasswordChangeVMType {
    func transform(input: PasswordChangeVMInput) -> PasswordChangeVMOuput
    func closeView()
    func navigateToSetPassword()
}

struct PasswordChangeVMInput {
    /// called when a screen becomes visible
    let appear: AnyPublisher<Void, Never>
    /// triggered when the email has been entered
    let newPasswordValidation: AnyPublisher<String, Never>
    /// triggered when the password has been entered
    let confirmPasswordValidation: AnyPublisher<String, Never>
    /// triggered when the sign in button did tap
    let updatePassword: AnyPublisher<Void, Never>
    /// triggered when the password has been entered
    let previousPasswordValidation: AnyPublisher<String, Never>
}

enum PasswordChangeVCState {
    case idle
    case loading
    case newPasswordValidation(TextFieldState)
    case previousPasswordValidation(TextFieldState)
    case confirmPasswordValidation(ConfirmPasswordState)
    case passwordUpdate(Bool)
    case failure(ServerError)
    case success
}

extension PasswordChangeVCState: Equatable {
    static func == (lhs: PasswordChangeVCState, rhs: PasswordChangeVCState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.loading, .loading): return true
        case (.success, .success): return true
        case (.failure, .failure): return true
        case let (.newPasswordValidation(a), .newPasswordValidation(b)): return a == b
        case let (.confirmPasswordValidation(a), .confirmPasswordValidation(b)): return a == b
        case let (.previousPasswordValidation(a), .previousPasswordValidation(b)): return a == b
        default: return false
        }
    }
}
