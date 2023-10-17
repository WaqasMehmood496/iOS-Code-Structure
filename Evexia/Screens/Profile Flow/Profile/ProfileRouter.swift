//
//  ProfileRouter.swift
//  Evexia
//
//  Created by  Artem Klimov on 20.08.2021.
//

import Foundation

typealias ProfileRoutes = SettingsRoute & ProfileEditRoute & BenefitsRoute & AdviseRoute & WellbeingRoute & PersonalDevelopmentRoute & AchievmentsRoute & MyImpactsRoute & SignInRoute

protocol ProfileNavigation: ProfileRoutes {
    func navigateToSettings()
    func navigateToProfileEdit()
    func navigateToBenefits()
    func navigateToAdvise()
    func navigateToStatistic(statisticType: StatisticType)
    func navigateToPersonalDevelopment()
    func navigateToAchievments(dailySteps: Int)
    func navigateToMyImpact()
    func navigateToSignIn()
}

class ProfileRouter: Router<ProfileVC>, ProfileNavigation {
     
    var impactTransition: Transition {
        return PushTransition()
    }
    
    var wellbeingTransition: Transition {
        return PushTransition()
    }
    
    var adviseTransition: Transition {
        return PushTransition()
    }

    var benefitsTransition: Transition {
        return PushTransition()
    }
    
    var settingsTransition: Transition {
        return PushTransition()
    }
    
    var profileEditTransition: Transition {
        return PushTransition()
    }
    
    var pdTransition: Transition {
        return PushTransition()
    }
    
    func navigateToSettings() {
        self.showSettings()
    }
    
    func navigateToProfileEdit() {
        self.showProfileEdit(profileFlow: .edit)
    }
    
    func navigateToBenefits() {
        self.showBenefits()
    }
    
    func navigateToAdvise() {
        self.showAdvise()
    }
    
    func navigateToStatistic(statisticType: StatisticType) {
        self.showWellbeing(statisticType: statisticType)
    }
    
    func navigateToPersonalDevelopment() {
        self.showPersonalDevelopment()
    }
    
    func navigateToAchievments(dailySteps: Int) {
        self.showAchievments(dailySteps: dailySteps)
    }

    func navigateToMyImpact() {
        self.showImpact()
    }
    
    var signInTransition: Transition {
        return RootTransition()
    }
    
    func navigateToSignIn() {
        self.showSignIn()
    }
}
