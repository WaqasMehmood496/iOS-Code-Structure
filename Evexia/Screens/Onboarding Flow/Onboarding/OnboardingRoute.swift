//
//  OnboardingRoute.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 18.07.2021.
//

import Foundation

protocol OnboardingRoute {

    var onboardingTransition: Transition { get }
    
    func showOnboarding()
}

extension OnboardingRoute where Self: RouterProtocol {
    func showOnboarding() {
        let vc = OnboardingBuilder.build(injector: self.injector)
        open(vc, transition: onboardingTransition)
    }
}
