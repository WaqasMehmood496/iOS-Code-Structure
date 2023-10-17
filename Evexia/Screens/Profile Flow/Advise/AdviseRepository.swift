//
//  AdviseRepository.swift
//  Evexia
//
//  Created by admin on 01.10.2021.
//

import Foundation
import Combine

// MARK: - AdviseRepositoryProtocol
protocol AdviseRepositoryProtocol {
    func getSupport() -> AnyPublisher<[AdviseModel], Never>
}

// MARK: - AdviseRepository
final class AdviseRepository {
    private let benefitsNetworkProvider: BenefitsNetworkProviderProtocol
    
    init (benefitsNetworkProvider: BenefitsNetworkProviderProtocol) {
        self.benefitsNetworkProvider = benefitsNetworkProvider
    }
}

// MARK: - AdviseRepository: AdviseRepositoryProtocol
extension AdviseRepository: AdviseRepositoryProtocol {
    
    func getSupport() -> AnyPublisher<[AdviseModel], Never> {
        return benefitsNetworkProvider.getSupport()
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
}
