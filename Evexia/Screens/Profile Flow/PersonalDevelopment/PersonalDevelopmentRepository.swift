//
//  PersonalDevelopmentRepository.swift
//  Evexia Staging
//
//  Created by Oleg Pogosian on 07.12.2021.
//

import Foundation
import Combine

// MARK: - AdviseRepositoryProtocol
protocol PersonalDevelopmentRepositoryProtocol {
    func getPDCategories() -> AnyPublisher<PersonalDevCategory, Never>
}

// MARK: - AdviseRepository
final class PersonalDevelopmentRepository {
    private let pdNetworkProvider: PersonalDevelopmentNetworkProviderProtocol
    
    init (pdNetworkProvider: PersonalDevelopmentNetworkProviderProtocol) {
        self.pdNetworkProvider = pdNetworkProvider
    }
}

// MARK: - AdviseRepository: AdviseRepositoryProtocol
extension PersonalDevelopmentRepository: PersonalDevelopmentRepositoryProtocol {
    
    func getPDCategories() -> AnyPublisher<PersonalDevCategory, Never> {
        return pdNetworkProvider.getAllPersonalDevelopmentCategories()
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
}
