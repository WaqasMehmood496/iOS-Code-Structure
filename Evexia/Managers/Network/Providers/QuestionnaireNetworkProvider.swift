//
//  QuestionnaireNetworkProvider.swift
//  Evexia
//
//  Created by admin on 25.09.2021.
//

import Foundation
import Combine

protocol QuestionnaireNetworkProviderProtocol {
    
    /**
    Get all task for current plan for time in DiaryRequestModel.
    Should return DiaryResponseModel model in positive cases with DiaryTaskModels. In case of error should return ServerError.
    */
    func getPulse() -> AnyPublisher<QuestionnaireModel, ServerError>
    
    func getWellbeing() -> AnyPublisher<QuestionnaireModel, ServerError>
    
    func completePulse(with model: QuestionnaireRequestModel, questionareId: String) -> AnyPublisher<BaseResponse, ServerError>

    func completeWellbeing(with model: QuestionnaireRequestModel, questionareId: String) -> AnyPublisher<WellbeilngResponseModel, ServerError>

}

final class QuestionnaireNetworkProvider: NetworkProvider, QuestionnaireNetworkProviderProtocol {
    func getPulse() -> AnyPublisher<QuestionnaireModel, ServerError> {
        return request(.getPulse)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getWellbeing() -> AnyPublisher<QuestionnaireModel, ServerError> {
        return request(.getWellbeing)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func completePulse(with model: QuestionnaireRequestModel, questionareId: String) -> AnyPublisher<BaseResponse, ServerError> {
        return request(.completePulse(model: model, questionareId: questionareId))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func completeWellbeing(with model: QuestionnaireRequestModel, questionareId: String) -> AnyPublisher<WellbeilngResponseModel, ServerError> {
        return request(.completeWellbeing(model: model, questionareId: questionareId))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
