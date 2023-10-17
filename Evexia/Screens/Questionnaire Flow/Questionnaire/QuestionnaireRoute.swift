//
//  QuestionnaireRoute.swift
//  Evexia
//
//  Created by admin on 28.09.2021.
//

import Foundation

protocol QuestionnaireRoute {
    
    var questionnaireTransition: Transition { get }
    
    func showQuestionnaire(surveyType: SurveyType, model: QuestionnaireModel)
}

extension QuestionnaireRoute where Self: RouterProtocol {
    func showQuestionnaire(surveyType: SurveyType, model: QuestionnaireModel) {
        let vc = QuestionnaireBuilder.build(injector: injector, surveyType: surveyType, model: model)
        open(vc, transition: questionnaireTransition)
    }
}
