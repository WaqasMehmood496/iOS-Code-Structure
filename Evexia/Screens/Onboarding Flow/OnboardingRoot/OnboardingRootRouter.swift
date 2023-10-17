//
//  OnboardingRootRouter.swift
//  Evexia
//
//  Created by  Artem Klimov on 19.07.2021.
//

import UIKit

class OnboardingRootRouter: Router<OnboardingRootVC> {
    
    func collectViewControllers(profileFlow: ProfileEditScreenFlow, nextViewTrigger: @escaping () -> Void) -> [UIViewController] {
        let personalPlanVC = PersonalPlanBuilder.build(injector: injector, nextViewTrigger: nextViewTrigger)
        
        let myWhyVC = MyWhyBuilder.build(injector: self.injector, nextViewTrigger: nextViewTrigger)
        
        let myGoalsViewController = MyGoalsBuilder.build(injector: self.injector, nextViewTrigger: nextViewTrigger)
        
        let myAvailability = MyAvailabilityBuilder.build(injector: self.injector, nextViewTrigger: nextViewTrigger, profileFlow: profileFlow)
        
        if profileFlow != .changePlanAfterEndPeriod {
            let profileVC = ProfileEditBuilder.build(injector: injector, nextViewTrigger: nextViewTrigger, profileFlow: .onboarding)
            return [personalPlanVC, myWhyVC, myGoalsViewController, myAvailability, profileVC]
        }
        
        return [personalPlanVC, myWhyVC, myGoalsViewController, myAvailability]
        
    }
}
