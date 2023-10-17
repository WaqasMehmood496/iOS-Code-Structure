//
//  SignUpRepository.swift
//  Evexia
//
//  Created by  Artem Klimov on 30.06.2021.
//

import Combine
import Foundation

// MARK: SignUpRepositoryProtocol
protocol SignUpRepositoryProtocol {
    var verification: PassthroughSubject<Result<AuthResponseModel, ServerError>, Never> { get set }
    
    func signUp(with name: String, and password: String) -> AnyPublisher<Result<BaseResponse, Error>, Never>
    func refreshFCMTokenRequest()
    func subscribeOnVerificationToken()
    func unsubscribeOnVerificationToken()
}

// MARK: SignUpRepository
class SignUpRepository {
    
    // MARK: Properties
    var verification = PassthroughSubject<Result<AuthResponseModel, ServerError>, Never>()
    
    var authNetworkProvider: UserNetworkProviderProtocol
    private var tokenSubscription: AnyCancellable?
    private var cancellables: [AnyCancellable] = []
    
    init(authNetworkProvider: UserNetworkProviderProtocol) {
        self.authNetworkProvider = authNetworkProvider
    }
    
    private func saveUserCreds(email: String) {
        UserDefaults.email = email
        UserDefaults.isSignUpInProgress = true
    }
}

// MARK: SignUpRepository: SignUpRepositoryProtocol
extension SignUpRepository: SignUpRepositoryProtocol {
    
    func signUp(with name: String, and password: String) -> AnyPublisher<Result<BaseResponse, Error>, Never> {
        let authModel = UserAuthModel(email: name, password: password, fbToken: UserDefaults.firebaseCMTokenStorage ?? "")
        return self.authNetworkProvider.signUp(model: authModel)
            .map({ [weak self] response -> Result<BaseResponse, Error> in
                self?.saveUserCreds(email: name)
                return .success(response)
            })
            .catch({ error -> AnyPublisher<Result<BaseResponse, Error>, Never> in
                return .just(.failure(error))
            })
            .eraseToAnyPublisher()
    }
    
    func refreshFCMTokenRequest() {
    
        guard let fcmToken = UserDefaults.firebaseCMTokenStorage else { return }
        authNetworkProvider.refreshFCMToken(token: fcmToken)
    }
    
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
    
    func subscribeOnVerificationToken() {
        self.tokenSubscription = UserDefaults.$verificationToken
            .sink(receiveValue: { [weak self] verificationToken in
                guard let token = verificationToken else { return }
                self?.verify(with: token)
            })
    }
    
    func unsubscribeOnVerificationToken() {
        guard let subscription = tokenSubscription else { return }
        subscription.cancel()
    }
}
