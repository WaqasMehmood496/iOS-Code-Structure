//
//  SetPasswordVMType.swift
//  Evexia
//
//  Created by  Artem Klimov on 06.07.2021.
//

import Foundation
import Combine

typealias SetPasswordVMOuput = AnyPublisher<SetPasswordVCState, Never>

protocol SetPasswordVMType {
    func transform(input: SetPasswordVMInput) -> SetPasswordVMOuput
    func applyNavigation()
}

struct SetPasswordVMInput {
    /// called when a screen becomes visible
    let appear: AnyPublisher<Void, Never>
    /// triggered when the email has been entered
    let newPasswordValidation: AnyPublisher<String, Never>
    /// triggered when the password has been entered
    let confirmPasswordValidation: AnyPublisher<String, Never>
    /// triggered when the sign in button did tap
    let updatePassword: AnyPublisher<String, Never>
}

enum SetPasswordVCState {
    case idle
    case loading
    case newPasswordValidation(TextFieldState)
    case confirmPasswordValidation(ConfirmPasswordState)
    case passwordUpdate(Bool)
    case failure(ServerError)
    case success
}

extension SetPasswordVCState: Equatable {
    static func == (lhs: SetPasswordVCState, rhs: SetPasswordVCState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.loading, .loading): return true
        case (.success, .success): return true
        case (.failure, .failure): return true
        case let (.newPasswordValidation(a), .newPasswordValidation(b)): return a == b
        case let (.confirmPasswordValidation(a), .confirmPasswordValidation(b)): return a == b
        default: return false
        }
    }
}
