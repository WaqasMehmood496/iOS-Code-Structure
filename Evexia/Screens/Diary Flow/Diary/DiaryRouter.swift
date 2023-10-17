//
//  DiaryRouter.swift
//  Evexia
//
//  Created by admin on 07.09.2021.
//

import Foundation

typealias DiaryRoutes = DiaryCalendarRoute & OnboardingRootRoute & AchievmentsRoute

protocol DiaryNavigation: DiaryRoutes {
    
    func navigateToPersonalPlan(profileFlow: ProfileEditScreenFlow)
    func navigateToAchievementScreen(steps: Int)
}

class DiaryRouter: Router<DiaryVC>, DiaryNavigation {
    
    var changeOnboardingRooTransition: Transition {
        return PushTransition()
    }
    
    var onboardingRootTransition: Transition {
        return RootTransition()
    }
    
    var pdTransition: Transition {
        return PushTransition()
    }
    
    var diaryCalendarTransition: Transition {
        return ModalTransition(animator: nil, isAnimated: true, modalTransitionStyle: .coverVertical, modalPresentationStyle: .automatic)
    }
    
    func navigateToPersonalPlan(profileFlow: ProfileEditScreenFlow) {
        self.showOnboardingRoot(profileFlow: profileFlow)
    }
    
    func navigateToAchievementScreen(steps: Int) {
        self.showAchievments(dailySteps: steps)
    }
}
