//
//  MyImpactVM.swift
//  Evexia
//
//  Created by Oleksand Kovalov on 15.02.2022.
//  
//

import Combine

// MARK: - MyImpactVM
final class MyImpactVM {
    
    // MARK: - Properties
    private var cancellables: [AnyCancellable] = []
    private let repository: MyImpactRepositoryProtocol
    
    var dataSource = CurrentValueSubject<[CarboneModel], Never>([])
    
    // MARK: - Init
    init(repository: MyImpactRepositoryProtocol) {
        self.repository = repository
        self.binding()
    }
    
    private func binding() {
        repository.dataSource
            .assign(to: \.value, on: dataSource)
            .store(in: &cancellables)
    }
}

// MARK: - Private Methods
private extension MyImpactVM { }
