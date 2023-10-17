//
//  SignUpRouter.swift
//  Evexia
//
//  Created by  Artem Klimov on 30.06.2021.
//

import Foundation
import Combine

// MARK: - SignUpRouterRoutes
typealias SignUpRouterRoutes = SignInRoute & VerificationRoute & AgreementsRoute & ExternalRoute & OnboardingRoute & RootRoute

// MARK: - SignUpNavigation: SignUpRouterRoutes
protocol SignUpNavigation: SignUpRouterRoutes {
    func navigateToSignIn()
    func navigateToOnboarding()
    func navigateToVerification(for email: String)
    func navigateToAgreements(type: Agreements)
    func showAppleSignIn(dismissSocialWebView: PassthroughSubject<Int?, Never>)
    func showGoogleSignIn(dismissSocialWebView: PassthroughSubject<Int?, Never>)
}

// MARK: - SignUpRouter
class SignUpRouter: Router<SignUpVC>, SignUpNavigation {
    var rootTransition: Transition {
        return RootTransition(removeNavigation: true)
    }
    
    var onboardingTransition: Transition {
        return ReplacingPushTransition()
    }
    
    var extenralTransition: Transition {
        return ModalTransitionWithNavigation(modalPresentationStyle: .automatic)
    }
    
    var verificationTransition: Transition {
        return PushTransition()
    }
    
    var setPasswordTransition: Transition {
        return ReplacingPushTransition()
    }
    
    var signInTransition: Transition {
        return ReplacingPushTransition()
    }
    
    var agreementsTransition: Transition {
        return PushTransition()
    }
    
    func navigateToSignIn() {
        self.showSignIn()
    }
    
    func navigateToOnboarding() {
        self.showOnboarding()
    }
    
    func navigateToVerification(for email: String) {
        self.showVerification(for: email)
    }
    
    func navigateToAgreements(type: Agreements) {
        self.showAgreements(type: type)
    }
    
    func showAppleSignIn(dismissSocialWebView: PassthroughSubject<Int?, Never>) {
        self.showExternal(webViewType: .signInWithApple, dismissSocialWebView: dismissSocialWebView)
    }
    
    func showGoogleSignIn(dismissSocialWebView: PassthroughSubject<Int?, Never>) {
        self.showExternal(webViewType: .signInWithGoogle, dismissSocialWebView: dismissSocialWebView)
    }
}
