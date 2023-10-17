//
//  RootRouter.swift
//  Evexia Staging
//
//  Created by  Artem Klimov on 30.06.2021.
//

import Foundation
import UIKit
import Combine

typealias RootRoutes = SetPasswordRoute & QuestionnaireRoute & AchievmentsRoute & CommentsListRoute
 
protocol RootNavigation: RootRoutes {
    func navigateToSetPassword(token: String)
    func navigateToQuestionnaire(for surveyType: SurveyType, model: QuestionnaireModel)
    func navigateToAchievements(steps: Int)
    func select(_ index: TabBarItemType)
    func navigateToPost(post: LocalPost)
}

class RootRouter: Router<RootVC>, RootNavigation {
    var commentsListTransition: Transition {
        return ModalTransition(isAnimated: true, modalTransitionStyle: .coverVertical, modalPresentationStyle: .automatic)
    }
    
    var pdTransition: Transition {
        return ModalTransition(isAnimated: false)
    }
    
    var setPasswordTransition: Transition {
        return ModalTransition(isAnimated: true)
    }

    var questionnaireTransition: Transition {
        return ModalTransition(isAnimated: true, modalTransitionStyle: .coverVertical, modalPresentationStyle: .automatic)
    }
    
    func navigateToSetPassword(token: String) {
        self.showSetPassword(token: token)
    }
    
    func navigateToQuestionnaire(for surveyType: SurveyType, model: QuestionnaireModel) {
        self.showQuestionnaire(surveyType: surveyType, model: model)
        self.select(.dashboard)
    }
    
    func select(_ index: TabBarItemType) {
        self.viewController?.selectedIndex = index.rawValue
    }
    
    func navigateToAchievements(steps: Int) {
        let achievements = AchievmentsBuilder.build(injector: injector, dailySteps: steps)
        self.select(.profile)
        let tb = self.viewController as? UITabBarController
        let nc = tb?.viewControllers?.first as? UINavigationController
        nc?.pushViewController(achievements, animated: true)
    }
    
    func navigateToPost(post: LocalPost) {
        self.showCommentsList(post: post,
                              addRemoveLikePublisher: PassthroughSubject<String, Never>(),
                              addCommentPublisher: PassthroughSubject<LocalPost, Never>(),
                              viewType: .openPost)
    }
}
