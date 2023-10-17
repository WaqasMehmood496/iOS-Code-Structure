//
//  OnboardingVM.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 18.07.2021.
//

import Foundation
import Combine

final class OnboardingVM: OnboardingVMType {
    

    private let repository: ProjectsRepositoryProtocol
    

    // MARK: - Properties
    private let router: OnboardingNavigation
    
    init(router: OnboardingNavigation, repository: ProjectsRepositoryProtocol) {
        self.router = router
        UserDefaults.needShowDashBoardTutorial = true
        UserDefaults.allDataInDashBoardIsLoad = false
        UserDefaults.needShowDiaryTutorial = true
        UserDefaults.currentTutorial = .start
        UserDefaults.needShowLibraryTutorial = true
        self.repository = repository
    }
    
    // MARK: - Navigation
    func navigateToPersonalPlan(profileFlow: ProfileEditScreenFlow) {
        router.navigateToPersonalPlan(profileFlow: profileFlow)
    }
    
    func navigateToHome() {
        router.navigateToRoot()
    }
    
    func getProjects() -> AnyPublisher<ProjectResponseModel, ServerError> {
        return self.repository.getProjects()
   
    }
}
