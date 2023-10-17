//
//  QuestionnaireResultRouter.swift
//  Evexia
//
//  Created by admin on 28.09.2021.
//

import Foundation

typealias QuestionnaireRoutes = AdviseRoute

protocol QuestionnaireResultNavigation: QuestionnaireRoutes {
    func closeView()
    func navigateToLibrary()
    func navigateToDiary()
    func navigateToAdvise()
}

class QuestionnaireResultRouter: Router<QuestionnaireResultVC>, QuestionnaireResultNavigation {
    
    var adviseTransition: Transition {
        return ReplacingPushTransition()
    }
    
    func closeView() {
        self.openTransition = PushTransition()
        self.close()
    }
    
    func navigateToLibrary() {
        closeView()
        self.viewController?.tabBarController?.selectedIndex = TabBarItemType.library.rawValue
    }
    
    func navigateToDiary() {
        closeView()
        self.viewController?.tabBarController?.selectedIndex = TabBarItemType.diary.rawValue
    }
    
    func navigateToAdvise() {
        self.showAdvise()
    }
}
