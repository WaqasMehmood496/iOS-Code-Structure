//
//  PersonalDevelopmentVM.swift
//  Evexia Staging
//
//  Created by Oleg Pogosian on 07.12.2021.
//

import Foundation
import Combine

class PersonalDevelopmentVM: PersonalDevelopmentVMType {

    private var cancellables: [AnyCancellable] = []
    private let repository: PersonalDevelopmentRepositoryProtocol
    private let router: PersonalDevelopmentRouter
    
    init(repository: PersonalDevelopmentRepositoryProtocol, router: PersonalDevelopmentRouter) {
        self.repository = repository
        self.router = router
    }
    
    func transform(input: PersonalDevelopmentVMInput) -> PersonalDevelopmentVMOutput {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        let idle = input.appear
            .flatMap { [weak self] in
                return self?.repository.getPDCategories() ?? .just([])
            }
            .receive(on: DispatchQueue.main)
            .map { [weak self] models -> PersonalDevelopmentVCState in
                let pdModels = self?.generateDataSource(for: models) ?? []
                return .idle(pdModels)
            }.eraseToAnyPublisher()
        
        return idle
    }
    
    private func generateDataSource(for models: PersonalDevCategory) -> PersonalDevCategory {
        // TODO: - check what i need to do here
        return models
       
    }
    
    func applyNavigation(id: Int, title: String) {
        self.router.showCategoryWith(id: id, title: title)
    }
}
