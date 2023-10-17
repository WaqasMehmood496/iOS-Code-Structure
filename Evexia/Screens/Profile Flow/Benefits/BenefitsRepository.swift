//
//  BenefitsRepository.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 20.08.2021.
//

import Foundation
import Combine

protocol BenefitsRepositoryProtocol {
    
    func retrieveBenefits() -> AnyPublisher<Result<[Benefit], ServerError>, Never>
    
    func incrementView(id: String)
}

final class BenefitsRepository {
    
    private var benefitsNetworkProvider: BenefitsNetworkProviderProtocol
    private let limit = 20
    private var page = 1
    private var isLastPage = false
    private var cancellables = Set<AnyCancellable>()
    private var dataSource = [Benefit]()
    private var isActiveRequest = false
    
    init(benefitsNetworkProvider: BenefitsNetworkProviderProtocol) {
        self.benefitsNetworkProvider = benefitsNetworkProvider
    }
    
    private func updatePaging(with response: BenefitResponseModel) {
        self.isLastPage = dataSource.count >= response.total
        if !isLastPage {
            self.page += 1
        }
    }
}

extension BenefitsRepository: BenefitsRepositoryProtocol {
    
    func retrieveBenefits() -> AnyPublisher<Result<[Benefit], ServerError>, Never> {
        if isLastPage || isActiveRequest {
            return .just(.success([]))
        }
        isActiveRequest = true
        
        let requestModel = BenefitRequestModel(limit: self.limit, counter: self.page)
        
        return benefitsNetworkProvider.fetchBenefits(with: requestModel)
            .map { [weak self] response -> Result<[Benefit], ServerError> in
                self?.dataSource.append(contentsOf: response.data)
                self?.updatePaging(with: response)
                self?.isActiveRequest = false
                return .success(response.data)
            }
            .catch { [weak self] error -> AnyPublisher<Result<[Benefit], ServerError>, Never> in
                self?.isActiveRequest = false
                return .just(.failure(error))
            }
            .eraseToAnyPublisher()
    }
    
     func incrementView(id: String) {
        self.benefitsNetworkProvider.incrementBenefitsViews(id: id)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { _ in })
            .store(in: &cancellables)
    }
}
