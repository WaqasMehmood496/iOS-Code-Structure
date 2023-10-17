//
//  QuestionnaireBuilder.swift
//  Evexia
//
//  Created by admin on 26.09.2021.
//

import Foundation
import UIKit
import Swinject

final class QuestionnaireBuilder {
    static func build(injector: Container, surveyType: SurveyType, model: QuestionnaireModel) -> QuestionnaireVC {
        let vc = QuestionnaireVC.board(name: .questionnaire)
        let router = QuestionnaireRouter(injector: injector)
        router.viewController = vc
        let repository = QuestionnaireRepository(questionnaireNetworkProvider: injector.resolve(QuestionnaireNetworkProvider.self)!)
        let viewModel = QuestionnaireVM(router: router, repository: repository, surveyType: surveyType, model: model)
        vc.viewModel = viewModel
        return vc
    }
}
