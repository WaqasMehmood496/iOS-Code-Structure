//
//  MyWhyRepository.swift
//  Evexia
//
//  Created by  Artem Klimov on 13.07.2021.
//

import Foundation
import Combine

// MARK: MyWhyRepositoryProtocol
protocol MyWhyRepositoryProtocol {
    func getMyWhyList() -> AnyPublisher<Result<[MyWhyModel], ServerError>, Never>
    func setMyWhy() -> AnyPublisher<Result<BaseResponse, ServerError>, Never>
    
    var selectionCounter: CurrentValueSubject<(Int, Int), Never> { get }
}

// MARK: MyWhyRepository
class MyWhyRepository {
    
    var selectionCounter: CurrentValueSubject<(Int, Int), Never>

    private let maxSeletections = 5
    private var previousSelections = 0
    private var dataSource = CurrentValueSubject<[MyWhyModel], Never>([])
    private var onboardingNetworkProvider: OnboardingNetworkProviderProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(onboardingNetworkProvider: OnboardingNetworkProviderProtocol) {
        self.onboardingNetworkProvider = onboardingNetworkProvider
        self.selectionCounter = CurrentValueSubject<(Int, Int), Never>((0, self.maxSeletections))
        self.binding()
    }
    
    private func binding() {
        self.dataSource
            .flatMap({ models in
                return Publishers.MergeMany(models.map({ $0.isSelected }))
            })
            .sink { [weak self] _ in
                self?.updateSelection()
            }.store(in: &self.cancellables)
    }
    
    private func configDataSource(for models: [MyWhyResponseModel]) -> Result<[MyWhyModel], ServerError> {
        let myWhyModels = models.map { MyWhyModel(value: $0.order, title: $0.title) }
        self.dataSource.send(myWhyModels)
        return .success(myWhyModels)
    }
    
    private func updateSelection() {
        let selected = self.dataSource.value.filter { $0.isSelected.value == true }
        self.selectionCounter.value = (selected.count, self.maxSeletections)
        
        if self.selectionCounter.value.0 == self.maxSeletections {
            self.dataSource.value.filter({ $0.isSelected.value == false }).forEach({ $0.selectionAvailabel.value = false })
        } else if self.previousSelections == self.maxSeletections {
            self.dataSource.value.forEach({ $0.selectionAvailabel.value = true })
        }
        
        self.previousSelections = selectionCounter.value.0
    }
}

// MARK: MyWhyRepository: MyWhyRepositoryProtocol
extension MyWhyRepository: MyWhyRepositoryProtocol {
    
    func getMyWhyList() -> AnyPublisher<Result<[MyWhyModel], ServerError>, Never> {
        self.onboardingNetworkProvider.getMyWhyList()
            .map({ responseModels -> Result<[MyWhyModel], ServerError> in
                return self.configDataSource(for: responseModels)
            }).catch({ serverError -> AnyPublisher<Result<[MyWhyModel], ServerError>, Never> in
                return .just(.failure(serverError))
            })
            .eraseToAnyPublisher()
    }
    
    func setMyWhy() -> AnyPublisher<Result<BaseResponse, ServerError>, Never> {
        let myWhy = self.dataSource.value.filter { $0.isSelected.value == true }.map { $0.value }
        let sendModel = MyWhySendModel(data: myWhy)

        return self.onboardingNetworkProvider.setMyWhy(model: sendModel)
            .map({ responseModel -> Result<BaseResponse, ServerError> in
                return .success(responseModel)
            }).catch({ serverError -> AnyPublisher<Result<BaseResponse, ServerError>, Never> in
                return .just(.failure(serverError))
            })
            .eraseToAnyPublisher()
    }
}
