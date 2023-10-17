//
//  PasswordRecoveryVM.swift
//  Evexia
//
//  Created by  Artem Klimov on 02.07.2021.
//

import Foundation
import Combine

class PasswordRecoveryVM {
    
    // MARK: - Properties
    private var router: PasswordRecoveryRouter
    private var repository: PasswordRecoveryRepositoryProtocol
    private var cancellables: [AnyCancellable] = []
    
    init(router: PasswordRecoveryRouter, repository: PasswordRecoveryRepositoryProtocol) {
        self.router = router
        self.repository = repository
    }
}

// MARK: - PasswordRecoveryVM: PasswordRecoveryVMType
extension PasswordRecoveryVM: PasswordRecoveryVMType {

    func transform(input: PasswordRecoveryVMInput) -> PasswordRecoveryVMOuput {
        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()
        
        let emailValidationOutput: PasswordRecoveryVMOuput = input.emailValidation.map { email -> PasswordRecoveryVCState in
            if email.isEmpty {
                return .emailValidation(.normal)
            }
            return email.isValidEmail ? .emailValidation(.valid) : .emailValidation(.error)
        }.eraseToAnyPublisher()
        
        let loading: PasswordRecoveryVMOuput = input.recoverPassword.map { _ in .loading }.eraseToAnyPublisher()
        
        let recoveryPassword = input.recoverPassword.flatMap({ email in
            return self.repository.sendRecoverLink(for: email)
        })
        .receive(on: DispatchQueue.main)
        .map({ result -> PasswordRecoveryVCState in
            switch result {
            case .success:
                self.router.navigateToRecoveryVerification()
                return .success
            case let .failure(error):
                let serverError = error as? ServerError ?? ServerError(errorCode: .networkError)
                return .failure(serverError)
            }
        }).eraseToAnyPublisher()
        
        let passwordRecoveryAvailabel = emailValidationOutput
            .map({ email -> PasswordRecoveryVCState in
                let isValidLogin = email == .emailValidation(.valid)
                return .recoveryAvailable(isValidLogin)
            }).eraseToAnyPublisher()
        
        return Publishers.Merge4(emailValidationOutput, loading, recoveryPassword, passwordRecoveryAvailabel).eraseToAnyPublisher()
    }
    
    func navigateToSetPassword() {
        self.router.navigateToRecoveryVerification()
    }
}
