//
//  SettingsRouter.swift
//  Evexia
//
//  Created by  Artem Klimov on 09.08.2021.
//

import Foundation
import UIKit

typealias SettingsRoutes = AgreementsRoute & SignUpRoute & SignInRoute & PasswordChangeRoute & СommunityRoute & MeasurementSystemRoute

protocol SettingsNavigation: SettingsRoutes {
    func navigateToSignUp()
    func navigateToAgreements(type: Agreements)
    func navigateToSignIn()
    func navigateToPasswordChange()
    func open(_ url: URL)
}

class SettingsRouter: Router<SettingsVC>, SettingsNavigation {
    
    var communityTransition: Transition {
        return PushTransition()
    }
    
    var passwordChangeTransition: Transition {
        return PushTransition()
    }

    var signUpTransition: Transition {
        return RootTransition()
    }
    
    var signInTransition: Transition {
        return RootTransition()
    }
    
    var agreementsTransition: Transition {
        return PushTransition()
    }
    
    var measurementSystemTransition: Transition {
        return PushTransition()
    }

    func navigateToSignUp() {
        self.showSignUp()
    }
    
    func navigateToAgreements(type: Agreements) {
        self.showAgreements(type: type)
    }
    
    func navigateToSignIn() {
        self.showSignIn()
    }
    
    func navigateToPasswordChange() {
        self.showPasswordChange()
    }
    
    func navigateToMeasurementSystem() {
        showMeasurementSystem()
    }
    
    func open(_ url: URL) {
        UIApplication.shared.open(url)
    }
}
