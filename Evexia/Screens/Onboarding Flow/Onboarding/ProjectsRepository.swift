//
//  ProjectsRepository.swift
//  Evexia
//
//  Created by Codes Orbit on 12/10/2023.
//

import Foundation
import Combine

protocol ProjectsRepositoryProtocol {
    func getProjects()-> AnyPublisher<ProjectResponseModel, ServerError>
}

class ProjectsRepository {
    let onboardingNetworkProvider: OnboardingNetworkProviderProtocol
    
    init(onboardingNetworkProvider: OnboardingNetworkProviderProtocol) {
        self.onboardingNetworkProvider = onboardingNetworkProvider
    }
}

extension ProjectsRepository: ProjectsRepositoryProtocol {
    
    func getProjects() -> AnyPublisher<ProjectResponseModel, ServerError> {
        return self.onboardingNetworkProvider.getProjects()
    }
}
