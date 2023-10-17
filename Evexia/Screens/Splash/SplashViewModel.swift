//
//  SplashViewModel.swift
//  Evexia
//
//  Created by admin on 02.05.2022.
//

import Foundation
import Combine

class SplashViewModel {
    
    let router: SplashRouter
    let repository: SplashRepository
    var cancellables = Set<AnyCancellable>()
    
    init(router: SplashRouter, repository: SplashRepository) {
        self.router = router
        self.repository = repository
    }
    
    func checkLoginState() {
      //  self.router.navigateToOnboarding()
        guard let token = UserDefaults.accessToken, !token.isEmpty else {
            checkIsRegistrationInProgress()
            return
        }
        updateUserProfile()
    }
    
    private func updateUserProfile() {
        
        self.repository.getUserProfile()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    self?.navigateToSignIn()
                case .finished:
                    return
                }
            }, receiveValue: { [weak self] user in
                var user = user
                
                if !isMetricSystem {
                    let weight = user.weight.changeMeasurementSystem(unitType: .mass).value
                    let height = user.height.changeMeasurementSystem(unitType: .lengh).value
                    user.weight = weight
                    user.height = height
                }
                
                UserDefaults.userModel = user
                self?.checkIsDoneOnboarding(for: user)
            }).store(in: &cancellables)
    }
    
    private func checkIsDoneOnboarding(for user: User) {
        if user.age.isEmpty ||
            user.availability.duration.isNil ||
            user.country.isEmpty ||
            user.firstName.isEmpty ||
            user.email.isEmpty ||
            user.lastName.isEmpty ||
            user.gender.isNil {
            navigateToOnboarding()
        } else {
            navigateToRoot()
        }
    }
    
    private func checkIsRegistrationInProgress() {
        let isSignUpInProgress = UserDefaults.isSignUpInProgress ?? false
        guard let email = UserDefaults.email else {
            navigateToSignIn()
            return
        }
        if isSignUpInProgress {
            navigateToVerification(for: email)
        } else {
            navigateToSignIn()
        }
    }
    
    private func navigateToRoot() {
        self.router.showRoot()
    }
    
    private func navigateToOnboarding() {
        router.showOnboardingRoot(profileFlow: .onboarding)
    }
    
    private func navigateToSignIn() {
        router.showSignIn()
    }
    
    private func navigateToVerification(for email: String) {
        router.showVerification(for: email)
    }
    
}
