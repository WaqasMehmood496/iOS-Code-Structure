//
//  VerificationRepository.swift
//  Evexia
//
//  Created by  Artem Klimov on 01.07.2021.
//

import Foundation
import Combine

// MARK: VerificationRepositoryProtocol
protocol VerificationRepositoryProtocol {
    func resendVerification(to email: String) -> AnyPublisher<Result<BaseResponse, Error>, Never>
    func verify(with token: String)
    
    var verification: PassthroughSubject<Result<AuthResponseModel, ServerError>, Never> { get set }
}

// MARK: VerificationRepository
class VerificationRepository {
    
    // MARK: Properties
    var verification = PassthroughSubject<Result<AuthResponseModel, ServerError>, Never>()

    private var authNetworkProvider: UserNetworkProviderProtocol
    private var cancellables: [AnyCancellable] = []
    
    init(authNetworkProvider: UserNetworkProviderProtocol) {
        self.authNetworkProvider = authNetworkProvider
        
        self.observeVerificationToken()
    }
    
    private func observeVerificationToken() {
        UserDefaults.$verificationToken
            .removeDuplicates()
            .sink(receiveValue: { [weak self] verificationToken in
                guard let token = verificationToken else { return }
                self?.verify(with: token)
            }).store(in: &self.cancellables)
    }
}

// MARK: VerificationRepository: VerificationRepositoryProtocol

extension VerificationRepository: VerificationRepositoryProtocol {
   
    func verify(with token: String) {
        let sendModel = VerificationModel(token: token, fbToken: UserDefaults.firebaseCMToken ?? "")
        
        self.authNetworkProvider.verification(model: sendModel)
            .sink(receiveCompletion: { completion in
                switch completion {
                case let .failure(serverError):
                    self.verification.send(.failure(serverError))
                default:
                    break
                }
            }, receiveValue: { response in
                   UserDefaults.isSignUpInProgress = false
                   UserDefaults.isOnboardingDone = false
                   UserDefaults.accessToken = response.accessToken
                   UserDefaults.refreshToken = response.refreshToken

                   UserDefaults.userModel = response.user
                self.verification.send(.success(response))
            }).store(in: &cancellables)
    }
    
    func resendVerification(to email: String) -> AnyPublisher<Result<BaseResponse, Error>, Never> {
        return self.authNetworkProvider.resendVerification(to: email)
            .map({ response -> Result<BaseResponse, Error> in
                return .success(response)
            })
            .catch({ error -> AnyPublisher<Result<BaseResponse, Error>, Never> in
                return .just(.failure(error))
            })
            .eraseToAnyPublisher()
    }
}
