//
//  VerificationVM.swift
//  Evexia
//
//  Created by  Artem Klimov on 01.07.2021.
//

import Foundation
import Combine

class VerificationVM: VerificationVMType {
    
    // MARK: - Properties
    internal let email: String
    
    private var router: VerificationNavigation
    private var repository: VerificationRepositoryProtocol
    private var cancellables: [AnyCancellable] = []
    
    init(router: VerificationNavigation, repository: VerificationRepositoryProtocol, email: String) {
        self.email = email
        self.repository = repository
        self.router = router
    }
    
    func transform(input: VerificationVMInput) -> VerificationVMOuput {
        
        let retry = input.retry
            .flatMap { [unowned self] _ -> AnyPublisher<Result<BaseResponse, Error>, Never> in
                return self.repository.resendVerification(to: self.email)
            }
            .receive(on: DispatchQueue.main)
            .map { result -> VerificationVCState in
                switch result {
                case let .failure(error):
                    let serverError = error as? ServerError ?? ServerError(errorCode: .networkError)
                    return .failure(serverError)
                case .success:
                    return .success
                }
            }.eraseToAnyPublisher()
            
        let verify = repository.verification
                .receive(on: DispatchQueue.main)
                .map({ result -> VerificationVCState in
                    switch result {
                    case let .failure(serverError):
                        return .failure(serverError)
                    case .success:
                        self.router.navigateToOnboarding()
                        return .success
                    }
                }).eraseToAnyPublisher()
    
        return Publishers.Merge(verify, retry).eraseToAnyPublisher()
    }

    // MARK: - Navigation
    func navigateToSignUp() {
        self.router.navigateToSignUp()
    }
}
