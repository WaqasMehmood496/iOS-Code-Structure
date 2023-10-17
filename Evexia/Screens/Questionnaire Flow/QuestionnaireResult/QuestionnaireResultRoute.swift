//
//  QuestionnaireResultRoute.swift
//  Evexia
//
//  Created by admin on 28.09.2021.
//

import Foundation

protocol QuestionnaireResultRoute {
    
    var questionnaireResultTransition: Transition { get }
    
    func showQuestionnaireResults(for score: WellbeingScore)
}

extension QuestionnaireResultRoute where Self: RouterProtocol {
    func showQuestionnaireResults(for result: WellbeingScore) {
        let vc = QuestionnaireResultBuilder.build(injector: injector, result: result)
        open(vc, transition: questionnaireResultTransition)
    }
}
