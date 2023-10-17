//
//  OnboardingRootVM.swift
//  Evexia
//
//  Created by  Artem Klimov on 08.07.2021.
//

import Foundation
import UIKit
import Combine

enum OnboardingScreen: Int, CaseIterable {
    case personalPlan
    case myWhy
    case myGoals
    case availability
    case profile
    
    var nextScreen: OnboardingScreen {
        return OnboardingScreen(rawValue: self.rawValue + 1) ?? .profile
    }
    
    var previousScreen: OnboardingScreen {
        return OnboardingScreen(rawValue: self.rawValue - 1) ?? .personalPlan
    }
}

class OnboardingRootVM {
    var currentController = CurrentValueSubject<(OnboardingScreen, UIPageViewController.NavigationDirection), Never>((.personalPlan, .forward))
    
    private var router: OnboardingRootRouter
    let profileFlow: ProfileEditScreenFlow
    
    init(router: OnboardingRootRouter, profileFlow: ProfileEditScreenFlow) {
        self.router = router
        self.profileFlow = profileFlow
    }
    
    func collectViewControllers() -> [UIViewController] {
        let controllers = self.router.collectViewControllers(profileFlow: profileFlow) { [weak self] in self?.showNextView() }
        return controllers
    }

    func showNextView() {
        self.currentController.send((self.currentController.value.0.nextScreen, .forward))
    }
    
    func showPreviousScreen() {
        self.currentController.send((self.currentController.value.0.previousScreen, .reverse))
    }
}
