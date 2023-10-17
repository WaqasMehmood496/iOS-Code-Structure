//
//  BenefitsVM.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 20.08.2021.
//

import Foundation
import Combine

final class BenefitsVM: BenefitsVMType {

    // MARK: - Properties
    private var cancellables: [AnyCancellable] = []
    private var repository: BenefitsRepositoryProtocol
    private let router: BenefitsRouter
    private var isActiveRequest = false

    init(repository: BenefitsRepositoryProtocol, router: BenefitsRouter) {
        self.repository = repository
        self.router = router
    }
    
    func transform(input: BenefitsVMInput) -> BenefitsVMOutput {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        let appearOutput = appearPublisher(for: input.appear)
        return appearOutput
    }
    
    private func appearPublisher(for appear: AnyPublisher<Void, Never>) -> BenefitsVMOutput {
        return appear
            .flatMapLatest { [unowned self] in self.repository.retrieveBenefits() }
            .receive(on: DispatchQueue.main)
            .map { response -> BenefitsVCState in
                switch response {
                case let .failure(serverError):
                    return .failure(serverError)
                case let .success(models):
                    return .success(models)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func navigate(to benefit: Benefit) {
        guard let url = URL(string: benefit.url) else { return }
        self.router.open(url)
        self.repository.incrementView(id: benefit.id)
    }

}
