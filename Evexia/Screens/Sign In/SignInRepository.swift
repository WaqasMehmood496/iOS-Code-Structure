//
//  SignInRepository.swift
//  Evexia
//
//  Created by  Artem Klimov on 24.06.2021.
//

import Foundation
import Combine

// MARK: SignInRepositoryProtocol
protocol SignInRepositoryProtocol {
    var verification: PassthroughSubject<Result<AuthResponseModel, ServerError>, Never> { get set }
    
    func signIn(with name: String, and password: String) -> AnyPublisher<Result<User, Error>, Never>
    func refreshFCMTokenRequest()
    func subscribeOnVerificationToken()
    func unsubscribeOnVerificationToken()
}

// MARK: SignInRepository
class SignInRepository {
    
    // MARK: Properties
    var verification = PassthroughSubject<Result<AuthResponseModel, ServerError>, Never>()
    
    private var userNetworkProvider: UserNetworkProviderProtocol
    private var tokenSubscription: AnyCancellable?
    private var cancellables: [AnyCancellable] = []
    
    init(userNetworkProvider: UserNetworkProviderProtocol) {
        self.userNetworkProvider = userNetworkProvider
    }
    
    private func saveResponse(_ response: AuthResponseModel) -> Result<User, Error> {
        var user = response.user
        
        if !isMetricSystem {
            let weight = user.weight.changeMeasurementSystem(unitType: .mass).value
            let height = user.height.changeMeasurementSystem(unitType: .lengh).value
            user.weight = weight
            user.height = height
        }
        UserDefaults.userModel = user
        UserDefaults.accessToken = response.accessToken
        UserDefaults.refreshToken = response.refreshToken
        UserDefaults.isShowAchieve = response.user.isShownAchievements
        return Result.success(user)
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

// MARK: SignInRepository: SignInRepositoryProtocol
extension SignInRepository: SignInRepositoryProtocol {
    
    /// User sign in with email and password
    func signIn(with name: String, and password: String) -> AnyPublisher<Result<User, Error>, Never> {
        let userModel = UserAuthModel(email: name, password: password, fbToken: UserDefaults.firebaseCMTokenStorage ?? "")
        return userNetworkProvider.authenticate(model: userModel)
            .map({ [unowned self] response -> Result<User, Error> in
                return self.saveResponse(response)
            })
            .catch({ error -> AnyPublisher<Result<User, Error>, Never> in
                return .just(.failure(error))
            })
            .eraseToAnyPublisher()
    }
    
    func verify(with token: String) {
        let sendModel = VerificationModel(token: token, fbToken: UserDefaults.firebaseCMToken ?? "")
        
        self.userNetworkProvider.verification(model: sendModel)
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
    
    func refreshFCMTokenRequest() {
        guard let fcmToken = UserDefaults.firebaseCMTokenStorage else { return }
        userNetworkProvider.refreshFCMToken(token: fcmToken)
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
