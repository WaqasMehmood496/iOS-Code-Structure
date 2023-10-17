//
//  QuestionnaireRepository.swift
//  Evexia
//
//  Created by admin on 24.09.2021.
//

import Foundation
import Combine

protocol QuestionnaireRepositoryProtocol {
    func getPulse() -> AnyPublisher<QuestionnaireModel, ServerError>
    func getWellbeing() -> AnyPublisher<QuestionnaireModel, ServerError>
    func completePulse(with models: QuestionnaireRequestModel, questionareId: String) -> AnyPublisher<BaseResponse, ServerError>
    func completeWellbeing(with model: QuestionnaireRequestModel, questionareId: String) -> AnyPublisher<Int, ServerError>
}

class QuestionnaireRepository {
    
    private var questionnaireNetworkProvider: QuestionnaireNetworkProviderProtocol
    
    init(questionnaireNetworkProvider: QuestionnaireNetworkProviderProtocol) {
        self.questionnaireNetworkProvider = questionnaireNetworkProvider
    }
}

extension QuestionnaireRepository: QuestionnaireRepositoryProtocol {
    
    func getPulse() -> AnyPublisher<QuestionnaireModel, ServerError> {
        return self.questionnaireNetworkProvider.getPulse()
    }
    
    func getWellbeing() -> AnyPublisher<QuestionnaireModel, ServerError> {
        return self.questionnaireNetworkProvider.getWellbeing()
    }
    
    func completePulse(with model: QuestionnaireRequestModel, questionareId: String) -> AnyPublisher<BaseResponse, ServerError> {
        return self.questionnaireNetworkProvider.completePulse(with: model, questionareId: questionareId)
    }
    
    func completeWellbeing(with model: QuestionnaireRequestModel, questionareId: String) -> AnyPublisher<Int, ServerError> {
        return self.questionnaireNetworkProvider.completeWellbeing(with: model, questionareId: questionareId)
            .map { response in
                UserDefaults.userModel?.wellbeingScore = String(response.scoredPoints)
                return response.scoredPoints
            }.eraseToAnyPublisher()
    }
}
