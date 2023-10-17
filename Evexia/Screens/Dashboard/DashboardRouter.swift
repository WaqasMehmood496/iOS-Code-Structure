//
//  DashboardRouter.swift
//  Evexia
//
//  Created by admin on 15.09.2021.
//

import Foundation
import UIKit

typealias DashboardRoutes = QuestionnaireResultRoute & QuestionnaireRoute

protocol DashboardNavigation: DashboardRoutes {
    func navigateToQuestionnaire(for surveyType: SurveyType, model: QuestionnaireModel)
    func navigateToQuestionnaireResult(for score: WellbeingScore)
}

class DashboardRouter: Router<DashboardVC>, DashboardNavigation {

    var questionnaireResultTransition: Transition {
        return PushTransition()
    }

    var questionnaireTransition: Transition {
        return ModalTransition(animator: nil, isAnimated: true, modalTransitionStyle: .coverVertical, modalPresentationStyle: .automatic)
    }
    
    func navigateToQuestionnaire(for surveyType: SurveyType, model: QuestionnaireModel) {
        self.showQuestionnaire(surveyType: surveyType, model: model)
    }
    
    func navigateToQuestionnaireResult(for score: WellbeingScore) {
        self.showQuestionnaireResults(for: score)
    }
}
