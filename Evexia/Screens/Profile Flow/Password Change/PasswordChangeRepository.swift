//
//  PasswordChangeRepository.swift
//  Evexia
//
//  Created by  Artem Klimov on 16.08.2021.
//

import Foundation
import Combine

protocol PasswordChangeRepositoryProtocol {
    func updatePassword(with model: ChangePasswordModel) -> AnyPublisher<Result<Void, ServerError>, Never>
}

class PasswordChangeRepository {
    private var userNetworkProvider: UserNetworkProviderProtocol
    
    init(userNetworkProvider: UserNetworkProviderProtocol) {
        self.userNetworkProvider = userNetworkProvider
    }
}

extension PasswordChangeRepository: PasswordChangeRepositoryProtocol {
    
    func updatePassword(with model: ChangePasswordModel) -> AnyPublisher<Result<Void, ServerError>, Never> {
        return self.userNetworkProvider.changePassword(with: model)
            .map { responseModel -> Result<Void, ServerError> in
                UserDefaults.accessToken = responseModel.accessToken
                UserDefaults.refreshToken = responseModel.refreshToken
                return .success(())
            }.catch { serverError -> AnyPublisher<Result<Void, ServerError>, Never> in
                return .just(.failure(serverError))
            }.eraseToAnyPublisher()
    }
}
