//
//  PasswordRecoveryRepository.swift
//  Evexia
//
//  Created by  Artem Klimov on 02.07.2021.
//

import Foundation
import Combine

// MARK: - PasswordRecoveryRepositoryProtocol
protocol PasswordRecoveryRepositoryProtocol {
    func sendRecoverLink(for email: String) -> AnyPublisher<Result<BaseResponse, Error>, Never>
}

// MARK: - PasswordRecoveryRepository
class PasswordRecoveryRepository {
    private var userNetworkProvider: UserNetworkProviderProtocol
    
    init(userNetworkProvider: UserNetworkProviderProtocol) {
        self.userNetworkProvider = userNetworkProvider
    }

    private func saveUserEmail(_ email: String) {
        UserDefaults.standard.setValue(email, forKey: "email")
    }
}

// MARK: - PasswordRecoveryRepository
extension PasswordRecoveryRepository: PasswordRecoveryRepositoryProtocol {
    
    func sendRecoverLink(for email: String) -> AnyPublisher<Result<BaseResponse, Error>, Never> {
        return userNetworkProvider.sendRecoveryLink(for: email)
            .map({ [weak self] response -> Result<BaseResponse, Error> in
                self?.saveUserEmail(email)
                return .success(response)
            })
            .catch({ error -> AnyPublisher<Result<BaseResponse, Error>, Never> in
                return .just(.failure(error))
            })
            .eraseToAnyPublisher()
    }
}
