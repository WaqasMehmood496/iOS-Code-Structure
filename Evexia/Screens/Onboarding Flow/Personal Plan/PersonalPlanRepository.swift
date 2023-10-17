//
//  PersonalPlanRepository.swift
//  Evexia
//
//  Created by  Artem Klimov on 08.07.2021.
//

import Foundation
import Combine

protocol PersonalPlanRepositoryProtocol {
    func setPersonalPlan(with model: PlanRequestModel) -> AnyPublisher<BaseResponse, ServerError>
}

class PersonalPlanRepository {
    let onboardingNetworkProvider: OnboardingNetworkProviderProtocol
    
    init(onboardingNetworkProvider: OnboardingNetworkProviderProtocol) {
        self.onboardingNetworkProvider = onboardingNetworkProvider
    }
}

extension PersonalPlanRepository: PersonalPlanRepositoryProtocol {
    
    func setPersonalPlan(with model: PlanRequestModel) -> AnyPublisher<BaseResponse, ServerError> {
        return self.onboardingNetworkProvider.setPersonalPlan(with: model)
    }
}
