//
//  UserNetworkProvider.swift
//  Evexia
//
//  Created by  Artem Klimov on 24.06.2021.
//

import Foundation
import Combine

protocol UserNetworkProviderProtocol {
    /**
     Start authentication process
     Should return AuthResponseModel model in positive cases. In case of error should return ServerError.
     */
    func authenticate(model: UserAuthModel) -> AnyPublisher<AuthResponseModel, ServerError>
    
    /**
     Resend verification token
     Should return BaseReponse model  in positive cases. In case of error should return ServerError.
     */
    func resendVerification(to emil: String) -> AnyPublisher<BaseResponse, ServerError>
    
    /**
     Start registration process. Token for verification receive in email.
     Should return BaseReponse model  in positive cases. In case of error should return ServerError.
     */
    func signUp(model: UserAuthModel) -> AnyPublisher<BaseResponse, ServerError>
    
    /**
     Receive user model  data.
     Should return User model in positive cases. In case of error should return ServerError.
     */
    func getUserProfile() -> AnyPublisher<User, ServerError>
    
    /**
     Start password recovery process. Token for verification receive in email.
     Should return Base response model in positive cases. In case of error should return ServerError.
     */
    func sendRecoveryLink(for email: String) -> AnyPublisher<BaseResponse, ServerError>
    
    /**
     Update forgotten passwod.
     Should return User profile model and auth token in positive cases. In case of error should return ServerError.
     */
    func resetPassword(for model: ResetPasswordModel) -> AnyPublisher<AuthResponseModel, ServerError>
    
    /**
     Verification of new user.
     Should return User profile model and auth token in positive cases. In case of error should return ServerError.
     */
    func verification(model: VerificationModel) -> AnyPublisher<AuthResponseModel, ServerError>
    
    /**
     Setting new parofile avatar
     Should return image url in  AvatarResponseModel model in positive cases. In case of error should return ServerError.
     */
    func setAvatar(data: Data) -> AnyPublisher<AvatarResponseModel, ServerError>
    
    /**
     Update user profile
     Should return User profile model  in positive cases. In case of error should return ServerError.
     */
    func updateProfile(with model: UpdateProfileModel) -> AnyPublisher<User, ServerError>
    
    /**
     Update user weight
     Should return User profile model  in positive cases. In case of error should return ServerError.
     */
    func setWeight(to model: UpdateWeightModel) -> AnyPublisher<User, ServerError>
    
    /**
     Remove user avatar
     Should return Base response model  in positive cases. In case of error should return ServerError.
     */
    func deleteAvatar() -> AnyPublisher<BaseResponse, ServerError>
    
    /**
     Logout user
     Should return Base response model  in positive cases. In case of error should return ServerError.
     */
    func logout() -> AnyPublisher<BaseResponse, ServerError>
    
    /**
     Delete user account
     Should return Base response model  in positive cases. In case of error should return ServerError.
     */
    func deleteAccount() -> AnyPublisher<BaseResponse, ServerError>
    
    /**
     Chagne password for logged user
     Should return RefreshTokenResponseModel  in positive cases. In case of error should return ServerError.
     */
    func changePassword(with model: ChangePasswordModel) -> AnyPublisher<RefreshTokenResponseModel, ServerError>
    
    /**
     Refresh access and refresh tokens for and checking is valid user auth
     Should return RefreshTokenResponseModel  in positive cases. In case of error should return ServerError.
     */
    func refreshToken() -> AnyPublisher<RefreshTokenResponseModel, ServerError>
    
    /**
     Refresh FCM  tokens
     Should return BaseResponse  in positive cases. In case of error should return ServerError.
     */
    @discardableResult
    func refreshFCMToken(token: String) -> AnyPublisher<BaseResponse, ServerError>
    
    /**
     Once a day set my last visit
     Should return BaseResponse  in positive cases. In case of error should return ServerError.
     */
    func setLastVisit() -> AnyPublisher<BaseResponse, ServerError>
    
    func changeAchievementsApearance(isOn: Bool) -> AnyPublisher<ShowAchievementsModel, ServerError>
    
    /**
     Set steps when passed or one day(or more) or user has >= 7000 steps
     Should return StepsResponseModel  in positive cases. In case of error should return ServerError.
     */
    func setSteps(model: [LeaderboardSteps]) -> AnyPublisher<StepsResponseModel, ServerError>

    
    func syncLeaderboard(model: [LeaderboardSteps]) -> AnyPublisher<BaseResponse, ServerError>
}

final class UserNetworkProvider: NetworkProvider, UserNetworkProviderProtocol {
    
    func changePassword(with model: ChangePasswordModel) -> AnyPublisher<RefreshTokenResponseModel, ServerError> {
        return self.request(.changePassword(model: model))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func signUp(model: UserAuthModel) -> AnyPublisher<BaseResponse, ServerError> {
        return self.request(.signUp(model: model))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .eraseToAnyPublisher()
    }
    
    func authenticate(model: UserAuthModel) -> AnyPublisher<AuthResponseModel, ServerError> {
        return self.request(.signIn(model: model))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .eraseToAnyPublisher()
    }
    
    func getUserProfile() -> AnyPublisher<User, ServerError> {
        return self.request(.getUserProfile)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .eraseToAnyPublisher()
    }
    
    func sendRecoveryLink(for email: String) -> AnyPublisher<BaseResponse, ServerError> {
        return self.request(.passwordRecovery(email: email))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .eraseToAnyPublisher()
    }
    
    func resetPassword(for model: ResetPasswordModel) -> AnyPublisher<AuthResponseModel, ServerError> {
        return self.request(.resetPassword(model))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .eraseToAnyPublisher()
    }
    
    func verification(model: VerificationModel) -> AnyPublisher<AuthResponseModel, ServerError> {
        return self.request(.verification(model: model))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .eraseToAnyPublisher()
    }
    
    func setAvatar(data: Data) -> AnyPublisher<AvatarResponseModel, ServerError> {
        return self.request(.setAvatar(data: data))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .eraseToAnyPublisher()
    }
    
    func updateProfile(with model: UpdateProfileModel) -> AnyPublisher<User, ServerError> {
        return self.request(.updateProfile(model: model))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .eraseToAnyPublisher()
    }
    
    func setWeight(to model: UpdateWeightModel) -> AnyPublisher<User, ServerError> {
        return self.request(.setWeight(weight: model))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .eraseToAnyPublisher()
    }
    
    func deleteAvatar() -> AnyPublisher<BaseResponse, ServerError> {
        return self.request(.deleteAvatar)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<BaseResponse, ServerError> {
        return self.request(.logout)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .eraseToAnyPublisher()
    }
    
    func deleteAccount() -> AnyPublisher<BaseResponse, ServerError> {
        return self.request(.deleteAccount)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .eraseToAnyPublisher()
    }
    
    func resendVerification(to email: String) -> AnyPublisher<BaseResponse, ServerError> {
        return self.request(.resendVerification(email: email))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .eraseToAnyPublisher()
    }
    
    func refreshToken() -> AnyPublisher<RefreshTokenResponseModel, ServerError> {
        return self.request(.refreshToken)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .eraseToAnyPublisher()
    }
    
    @discardableResult
    func refreshFCMToken(token: String) -> AnyPublisher<BaseResponse, ServerError> {
        return self.request(.refreshFCMToken(token))
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    
    func setLastVisit() -> AnyPublisher<BaseResponse, ServerError> {
        return request(.lastVisit)
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    
    func changeAchievementsApearance(isOn: Bool) -> AnyPublisher<ShowAchievementsModel, ServerError> {
        return request(.changeAchievementsApearance(isOn: isOn))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .eraseToAnyPublisher()
    }
    
    func setSteps(model: [LeaderboardSteps]) -> AnyPublisher<StepsResponseModel, ServerError> {
        return request(.dashboardSteps(model: model))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .eraseToAnyPublisher()
    }
    
    func syncLeaderboard(model: [LeaderboardSteps]) -> AnyPublisher<BaseResponse, ServerError> {
        return self.request(.leaderboard(model: model)).eraseToAnyPublisher()
    }
    
}
