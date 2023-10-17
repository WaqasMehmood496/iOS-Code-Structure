//
//  AdviseVM.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 17.08.2021.
//

import Combine
import Foundation

final class AdviseVM: AdviseVMType {
    
    private var cancellables: [AnyCancellable] = []
    private let repository: AdviseRepositoryProtocol
    private let router: AdviseRouter
    
    init(repository: AdviseRepositoryProtocol, router: AdviseRouter) {
        self.repository = repository
        self.router = router
    }
    
    func transform(input: AdviseVMInput) -> AdviseVMOutput {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        let idle = input.appear
            .flatMap { [weak self] in
                return self?.repository.getSupport() ?? .just([])
            }
            .receive(on: DispatchQueue.main)
            .map { [weak self] models -> AdviseVCState in
                let adviseModels = self?.generateDataSource(for: models) ?? []
                return .idle(adviseModels)
            }.eraseToAnyPublisher()
        
        return idle
    }
    
    private func generateDataSource(for models: [AdviseModel]) -> [[AdviseModel]] {
        let sponsors = models.filter { $0.title != Advise.additional.title }
        
        var additionalAdvise = [AdviseModel]()

        if let additional = models.first(where: { $0.title == Advise.additional.title }) {
            additionalAdvise.append(additional)
        }
        
        return [sponsors, additionalAdvise]
    }
    
    func applyNavigation(for model: AdviseModel) {
        switch model.type {
        case .email:
            guard model.value.isValidEmail else { return }
            self.router.mail(to: model.value)
        case .tel:
            self.router.call(number: model.value.wrappedPhoneNumber)
        case .url:
            guard let url = URL(string: model.value) else { return }
            self.router.open(url)
        }
    }
}
