//
//  SignInRouter.swift
//  Evexia
//
//  Created by Yura Yatseyko on 23.06.2021.
//

import Foundation
import Combine

// MARK: - SignInRouterRoutes
typealias SignInRouterRoutes = RootRoute & SignUpRoute & PasswordRecoveryRoute & OnboardingRoute & ExternalRoute

// MARK: - SignInNavigation
protocol SignInNavigation: SignInRouterRoutes {
    func navigateToSignUp()
    func navigateToPasswordRecovery()
    func navigateToOnboarding()
    func navigateToRoot()
    func showAppleSignIn(dismissSocialWebView: PassthroughSubject<Int?, Never>)
    func showGoogleSignIn(dismissSocialWebView: PassthroughSubject<Int?, Never>)
}

// MARK: - SignInRouter
class SignInRouter: Router<SignInVC>, SignInNavigation {
    
    var extenralTransition: Transition {
        return ModalTransitionWithNavigation(modalPresentationStyle: .automatic)
    }
    
    var onboardingTransition: Transition {
        return RootTransition()
    }

    var passwordRecoveryTransition: Transition {
        return PushTransition()
    }

    var signUpTransition: Transition {
        return ReplacingPushTransition()
    }
    
    var rootTransition: Transition {
        return RootTransition(removeNavigation: true)
    }
    
    func navigateToSignUp() {
        self.showSignUp()
    }

    func navigateToRoot() {
        self.showRoot()
    }
    
    func navigateToPasswordRecovery() {
        self.showPasswordRecovery()
    }
    
    func navigateToOnboarding() {
        self.showOnboarding()
    }
    
    func showAppleSignIn(dismissSocialWebView: PassthroughSubject<Int?, Never>) {
        self.showExternal(webViewType: .signInWithApple, dismissSocialWebView: dismissSocialWebView)
    }
    
    func showGoogleSignIn(dismissSocialWebView: PassthroughSubject<Int?, Never>) {
        self.showExternal(webViewType: .signInWithGoogle, dismissSocialWebView: dismissSocialWebView)
    }
}
