//
//  QuestionnaireResultBuilder.swift
//  Evexia
//
//  Created by admin on 28.09.2021.
//

import Foundation
import Swinject

final class QuestionnaireResultBuilder {
    static func build(injector: Container, result: WellbeingScore) -> QuestionnaireResultVC {
        let vc = QuestionnaireResultVC.board(name: .questionnaireResult)
        
        let router = QuestionnaireResultRouter(injector: injector)
        router.viewController = vc
        let viewModel = QuestionnaireResultVM(router: router, result: result)
        vc.viewModel = viewModel
        return vc
    }
}
