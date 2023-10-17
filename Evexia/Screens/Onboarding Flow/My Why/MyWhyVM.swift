//
//  MyWhyVM.swift
//  Evexia
//
//  Created by  Artem Klimov on 13.07.2021.
//

import Foundation
import Combine

class MyWhyVM: MyWhyVMType {

    // MARK: - Properties
    private var router: MyWhyRouter
    private var repository: MyWhyRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(router: MyWhyRouter, repository: MyWhyRepositoryProtocol) {
        self.router = router
        self.repository = repository
    }
    
    func transform(input: MyWhyVMInput) -> MyWhyVMOuput {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        // Show loading spinner
        let loadingPublisher: MyWhyVMOuput = input.load.map { _ in .loading }.eraseToAnyPublisher()
        
        // Load list of MyWhy
        let idlePublisher = input.load
            .flatMap({ [weak self] _ -> AnyPublisher<Result<[MyWhyModel], ServerError>, Never> in
                guard let self = self else { return .empty() }
                return self.repository.getMyWhyList()
            })
            .map({ result -> MyWhyVCState in
                switch result {
                case let .failure(serverError):
                    return .failure(serverError)
                case let .success(models):
                    return .idle(models)
                }
            }).eraseToAnyPublisher()
        
        // Update counter selection label
        let updateSelectionPublisher = self.repository.selectionCounter
            .map({ value -> MyWhyVCState in
                return .udpateSelected(count: value.0, maxValue: value.1)
            }).eraseToAnyPublisher()
        
        // Update IsEnable button
        let isSetAvailabelPublisher = self.repository.selectionCounter
            .map({ value -> MyWhyVCState in
                return .nextAvailabel(value.0 > 0)
            }).eraseToAnyPublisher()
        
        // Set selected myWhy
        let setMyWhyPublisher = input.nextAction
            .flatMap({ [weak self] _ -> AnyPublisher<Result<BaseResponse, ServerError>, Never> in
                guard let self = self else { return .empty() }
                return self.repository.setMyWhy()
            })
            .receive(on: DispatchQueue.main)
            .map({ [weak self] result -> MyWhyVCState in
                switch result {
                case let .failure(serverError):
                    return .failure(serverError)
                case .success:
                    self?.router.nextViewTrigger?()
                    return .success
                }
            }).eraseToAnyPublisher()
        
        return Publishers.Merge5(idlePublisher, loadingPublisher, updateSelectionPublisher, isSetAvailabelPublisher, setMyWhyPublisher).eraseToAnyPublisher()
    }
}
