//
//  BenefitsNetworkProvider.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 24.08.2021.
//

import Combine

protocol BenefitsNetworkProviderProtocol {
    
    func fetchBenefits(with model: BenefitRequestModel) -> AnyPublisher<BenefitResponseModel, ServerError>
    
    func getSupport() -> AnyPublisher<[AdviseModel], ServerError>
    
    func incrementBenefitsViews(id: String) -> AnyPublisher<BaseResponse, ServerError>

}

final class BenefitsNetworkProvider: NetworkProvider, BenefitsNetworkProviderProtocol {
    
    func fetchBenefits(with model: BenefitRequestModel) -> AnyPublisher<BenefitResponseModel, ServerError> {
        return request(.benefits(model: model)).eraseToAnyPublisher()
    }
    
    func getSupport() -> AnyPublisher<[AdviseModel], ServerError> {
        return request(.support)
            .eraseToAnyPublisher()
    }
     
    func incrementBenefitsViews(id: String) -> AnyPublisher<BaseResponse, ServerError> {
        return request(.incrementBenefitViews(id: id))
            .eraseToAnyPublisher()
    }
}
