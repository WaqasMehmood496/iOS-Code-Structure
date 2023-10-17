//
//  SetPasswordRepository.swift
//  Evexia
//
//  Created by  Artem Klimov on 06.07.2021.
//

import Combine
import Foundation

// MARK: SetPasswordRepositoryProtocol
protocol SetPasswordRepositoryProtocol {
    func resetPassword(with password: String) -> AnyPublisher<Result<User, Error>, Never>
}

// MARK: SetPasswordRepository
class SetPasswordRepository {
    private var userNetworkProvider: UserNetworkProviderProtocol
    private var token: String
    
    init(userNetworkProvider: UserNetworkProviderProtocol, token: String) {
        self.userNetworkProvider = userNetworkProvider
        self.token = token
    }
    
    private func saveResponse(_ response: AuthResponseModel) -> Result<User, Error> {
        UserDefaults.accessToken = response.accessToken
        UserDefaults.refreshToken = response.refreshToken
        UserDefaults.userModel = response.user
        return Result.success(response.user)
    }
}

// MARK: SetPasswordRepository: SetPasswordRepositoryProtocol
extension SetPasswordRepository: SetPasswordRepositoryProtocol {
    
    func resetPassword(with password: String) -> AnyPublisher<Result<User, Error>, Never> {
        let resetPasswordModel = ResetPasswordModel(fbToken: UserDefaults.firebaseCMToken ?? "", token: self.token, password: password)
        
        return self.userNetworkProvider.resetPassword(for: resetPasswordModel)
            .map({ [unowned self] response -> Result<User, Error> in
                return self.saveResponse(response)
            })
            .catch({ error -> AnyPublisher<Result<User, Error>, Never> in
                return .just(.failure(error))
            }).eraseToAnyPublisher()
    }
}
