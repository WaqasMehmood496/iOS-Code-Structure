//
//  QuestionnaireRouter.swift
//  Evexia
//
//  Created by admin on 28.09.2021.
//

import Foundation

protocol QuestionnaireNavigation {
    func closeView()
}

class QuestionnaireRouter: Router<QuestionnaireVC>, QuestionnaireNavigation {
    func closeView() {
        self.openTransition = ModalTransition()
        self.close()
    }
}
