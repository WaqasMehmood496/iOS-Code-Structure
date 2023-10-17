//
//  PasswordChangeVM.swift
//  Evexia
//
//  Created by Artem Klimov on 16.08.2021.
//

import Foundation
import Combine

class PasswordChangeVM: PasswordChangeVMType {
    
    // MARK: - Properties
    
    private let repository: PasswordChangeRepositoryProtocol
    private var router: PasswordChangeNavigation
    private var cancellables: [AnyCancellable] = []
    
    private var currentPassword = ""
    private var newPassword = ""
    private var confirmPassword = ""

    init(router: PasswordChangeNavigation, repository: PasswordChangeRepositoryProtocol) {
        self.router = router
        self.repository = repository
    }
    
    func transform(input: PasswordChangeVMInput) -> PasswordChangeVMOuput {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        let loading: PasswordChangeVMOuput = input.updatePassword.map { _ in .loading }
            .eraseToAnyPublisher()
        
        let passwordValidationOutput: PasswordChangeVMOuput = input.newPasswordValidation
            .map { password -> PasswordChangeVCState in
                if password.isEmpty {
                    return .newPasswordValidation(.normal)
                }
                return password.isValidPassword ? .newPasswordValidation(.valid) : .newPasswordValidation(.error)
            }.eraseToAnyPublisher()
        
        let matchValidation = Publishers.CombineLatest(input.newPasswordValidation, input.confirmPasswordValidation)
            .map { [weak self] new, confirm -> PasswordChangeVCState in
                self?.newPassword = new
                self?.confirmPassword = confirm
                
                if confirm.isEmpty {
                    return .confirmPasswordValidation(.normal)
                } else if new.isValidPassword {
                    let isMatch: ConfirmPasswordState = new == confirm ? .valid : .notMatch
                    return .confirmPasswordValidation(isMatch)
                } else {
                    let state: ConfirmPasswordState = confirm.isValidPassword ? .valid : .notValid
                    return .confirmPasswordValidation(state)
                }
            }
            .eraseToAnyPublisher()
        
        let previousPasswordValidationOutput: PasswordChangeVMOuput = input.previousPasswordValidation
            .map { [weak self] password -> PasswordChangeVCState in
                self?.currentPassword = password
                if password.isEmpty {
                    return .previousPasswordValidation(.normal)
                }
                return password.isValidPassword ? .previousPasswordValidation(.valid) : .previousPasswordValidation(.error)
            }.eraseToAnyPublisher()
        
        let updatePasswordAvailabel = Publishers.CombineLatest3(input.newPasswordValidation, input.confirmPasswordValidation, input.previousPasswordValidation)
            .map({ password, confirmPassword, previousPassword -> PasswordChangeVCState in
                return .passwordUpdate(password == confirmPassword && previousPassword.isValidPassword && password.isValidPassword)
            })
            .removeDuplicates()
            .eraseToAnyPublisher()

        let udpatePasswordOutput = input.updatePassword
            .flatMap { [weak self] _ -> AnyPublisher<Result<Void, ServerError>, Never> in
                guard let self = self else { return .empty() }
                
                let sendModel = ChangePasswordModel(oldPassword: self.currentPassword, newPassword: self.newPassword, confirmPassword: self.confirmPassword)
                return self.repository.updatePassword(with: sendModel)
            }
            .map { result -> PasswordChangeVCState in
                switch result {
                case let .failure(serverError):
                    return .failure(serverError)
                case .success:
                    return .success
                }
            }.eraseToAnyPublisher()
        
        return Publishers.MergeMany(passwordValidationOutput, loading, updatePasswordAvailabel, udpatePasswordOutput, previousPasswordValidationOutput, matchValidation)
            .eraseToAnyPublisher()
    }
    
    func closeView() {
        self.router.closeView()
    }
    
    func navigateToSetPassword() {
        self.router.showPasswordRecovery()
    }
}
