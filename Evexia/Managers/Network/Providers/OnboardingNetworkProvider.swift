//
//  OnboardingNetworkProvider.swift
//  Evexia
//
//  Created by  Artem Klimov on 16.07.2021.
//

import Foundation
import Combine

protocol OnboardingNetworkProviderProtocol {
    /**
     Receive my why statement list.
     Should return MyWhyResponseModel models in positive cases. In case of error should return ServerError.
     */
    func getMyWhyList() -> AnyPublisher<[MyWhyResponseModel], ServerError>
    
    /**
     Set my why priority statement.
     Should return BaseResponse model in positive cases. In case of error should return ServerError.
     */
    func setMyWhy(model: MyWhySendModel) -> AnyPublisher<BaseResponse, ServerError>
    
    /**
     Receive my goals statement list.
     Should return MyGoalsResponseModel models in positive cases. In case of error should return ServerError.
     */
    func getMyGoalsList() -> AnyPublisher<[MyGoalsResponseModel], ServerError>
    
    /**
     Set my goals.
     Should return BaseResponse modelsin positive cases. In case of error should return ServerError.
     */
    func setMyGoals(with model: MyGoalsSendModel) -> AnyPublisher<BaseResponse, ServerError>
    
    /**
     Set availability and program duration.
     Should return BaseResponse modelsin positive cases. In case of error should return ServerError.
     */
    func setAvailability(with model: Availability) -> AnyPublisher<BaseResponse, ServerError>
    
    /**
     Rewrite personal plan
     Should return BaseResponse modelsin positive cases. In case of error should return ServerError.
     */
    func resetPlan(with model: Availability) -> AnyPublisher<BaseResponse, ServerError>
    
    /**
     Set availability and program duration.
     Should return BaseResponse modelsin positive cases. In case of error should return ServerError.
     */
    func setPersonalPlan(with model: PlanRequestModel) -> AnyPublisher<BaseResponse, ServerError>
    
    /**
     Get Projects detail.
     Should return ProjectResponseModel models in positive cases. In case of error should return ServerError.
     */
    func getProjects() -> AnyPublisher<ProjectResponseModel, ServerError>
}

final class OnboardingNetworkProvider: NetworkProvider, OnboardingNetworkProviderProtocol {
    
    func getMyWhyList() -> AnyPublisher<[MyWhyResponseModel], ServerError> {
        return self.request(.getMyWhyList)
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    
    func setMyWhy(model: MyWhySendModel) -> AnyPublisher<BaseResponse, ServerError> {
        return self.request(.setMyWhy(model: model))
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    
    func getMyGoalsList() -> AnyPublisher<[MyGoalsResponseModel], ServerError> {
        return self.request(.getMyGoalsList)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .eraseToAnyPublisher()
    }
    
    func setMyGoals(with model: MyGoalsSendModel) -> AnyPublisher<BaseResponse, ServerError> {
        return self.request(.setMyGoals(model: model))
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    
    func setAvailability(with model: Availability) -> AnyPublisher<BaseResponse, ServerError> {
        return self.request(.setAvailability(model: model))
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    
    func resetPlan(with model: Availability) -> AnyPublisher<BaseResponse, ServerError> {
        return self.request(.resetPlan(model: model))
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    
    func setPersonalPlan(with model: PlanRequestModel) -> AnyPublisher<BaseResponse, ServerError> {
        return self.request(.personalPlan(model: model))
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    
    func getProjects() -> AnyPublisher<ProjectResponseModel, ServerError> {
        return self.request(.getProjects)
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
}
