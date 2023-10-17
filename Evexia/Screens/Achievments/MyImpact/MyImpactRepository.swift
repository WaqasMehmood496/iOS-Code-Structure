//
//  MyImpactRepository.swift
//  Evexia
//
//  Created by Oleksand Kovalov on 15.02.2022.
//

import Foundation
import Combine

// MARK: - MyImpactRepositoryProtocol
protocol MyImpactRepositoryProtocol {
    var dataSource: CurrentValueSubject<[CarboneModel], Never> { get }
}

// MARK: - MyImpactRepository
class MyImpactRepository {
    private var cancellables = Set<AnyCancellable>()
    var dataSource = CurrentValueSubject<[CarboneModel], Never>([])
    private var achievmentsNetworkProvider: AchievmentsNetworkProviderProtocol
    
    // MARK: - Init
    init(achievmentsNetworkProvider: AchievmentsNetworkProviderProtocol) {
        self.achievmentsNetworkProvider = achievmentsNetworkProvider
        getCarboneOffset()
    }
    
    // MARK: - Methods
    private func getCarboneOffset() {
        achievmentsNetworkProvider.getCarbonOffset()
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                self.dataSource.value = [.personalTotal(response.personalTotal), .companyTotal(response.companyTotal), .totalApp(response.totalApp)]
            })
            .store(in: &cancellables)

    }
}

// MARK: - MyImpactRepository: MyImpactRepositoryProtocol
extension MyImpactRepository: MyImpactRepositoryProtocol { }
