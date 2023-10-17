//
//  SetPasswordVM.swift
//  Evexia
//
//  Created by  Artem Klimov on 06.07.2021.
//

import Foundation
import Combine

class SetPasswordVM: SetPasswordVMType {

    // MARK: - Properties
    private let repository: SetPasswordRepositoryProtocol
    private var router: SetPasswordNavigation
    private var cancellables: [AnyCancellable] = []

    private var isPasswordsMatch = false
    
    init(router: SetPasswordNavigation, repository: SetPasswordRepositoryProtocol) {
        self.router = router
        self.repository = repository
    }
    
    func transform(input: SetPasswordVMInput) -> SetPasswordVMOuput {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    
        let loading: SetPasswordVMOuput = input.updatePassword.map { _ in .loading }
            .eraseToAnyPublisher()
                
        let passwordValidationOutput: SetPasswordVMOuput = input.newPasswordValidation.map { password -> SetPasswordVCState in
            if password.isEmpty {
                return .newPasswordValidation(.normal)
            }
            return password.isValidPassword ? .newPasswordValidation(.valid) : .newPasswordValidation(.error)
        }.eraseToAnyPublisher()
        
       let updatePasswordAvailabel = Publishers.CombineLatest(input.newPasswordValidation, input.confirmPasswordValidation)
            .map({ [weak self] password, confirmPasswor -> SetPasswordVCState in
                self?.isPasswordsMatch = password == confirmPasswor
                return .passwordUpdate(password == confirmPasswor)
            })
        
        let confirmPasswordValidationOutput = input.confirmPasswordValidation.map { [weak self] confirmPassword -> SetPasswordVCState in
            if confirmPassword.isEmpty {
                return .confirmPasswordValidation(.normal)
            } else if !confirmPassword.isValidPassword {
                return .confirmPasswordValidation(.notValid)
            } else {
                return self?.isPasswordsMatch ?? false ? .confirmPasswordValidation(.valid) : .confirmPasswordValidation(.notMatch)
            }
        }.eraseToAnyPublisher()
        
        let upadatePasswordPublisher = self.upadatePasswordPublisher(for: input.updatePassword)
        
        return Publishers.Merge5(passwordValidationOutput, confirmPasswordValidationOutput, loading, updatePasswordAvailabel, upadatePasswordPublisher)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    private func upadatePasswordPublisher(for updatePassword: AnyPublisher<String, Never>) -> SetPasswordVMOuput {
        return updatePassword.flatMap({ [unowned self] newPassword in
            return self.repository.resetPassword(with: newPassword)
        })
        .receive(on: DispatchQueue.main)
        .map({ result -> SetPasswordVCState in
            switch result {
            case let .failure(error):
                let serverError = error as? ServerError ?? ServerError(errorCode: .networkError)
                return .failure(serverError)
            case .success:
                return .success
            }
        }).eraseToAnyPublisher()
    }
    
    func applyNavigation() {
        guard let user = UserDefaults.userModel, !user.firstName.isEmpty, !user.country.isEmpty else {
            return self.router.navigateToOnboarding()
        }
        self.router.navigateToRoot()
    }
}
