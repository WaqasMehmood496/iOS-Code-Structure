//
//  MyGoalsVM.swift
//  Evexia
//
//  Created by  Artem Klimov on 19.07.2021.
//

import Foundation
import Combine

class MyGoalsVM: MyGoalsVMType {
    
    // MARK: - Properties
    var reconfigCellModel = PassthroughSubject<[FocusSection], Never>()
    
    private var repository: MyGoalsRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private var router: MyGoalsRouter

    init(router: MyGoalsRouter, repository: MyGoalsRepositoryProtocol) {
        self.router = router
        self.repository = repository
    }
    
    func transform(input: MyGoalsVMInput) -> MyGoalsVMOuput {
        
        // Show loading spinner
        let loadingOutput: MyGoalsVMOuput = input.load.map { _ in .loading }.eraseToAnyPublisher()
        
        // Load list of Goals
        let idleOutput = input.load
            .delay(for: .seconds(0.2), scheduler: RunLoop.current, options: .none)
            .flatMap({ [weak self] _ -> AnyPublisher<Result<[FocusSection], ServerError>, Never> in
                guard let self = self else { return .empty() }
                return self.repository.getMyGoalsList()
            })
            .map({ result -> MyGoalsVCState in
                switch result {
                case let .failure(serverError):
                    return .failure(serverError)
                case let .success(models):
                    return .idle(models)
                }
            }).eraseToAnyPublisher()
        
        // Update IsEnable button
        let isSetAvailabelOutput = self.repository.selectionCounter
            .map({ value -> MyGoalsVCState in
                return .nextAvailabel(value > 0)
            }).eraseToAnyPublisher()
        
        let setMyGoalsOutput = input.nextAction
            .flatMap { [weak self] _ -> AnyPublisher<Result<Void, ServerError>, Never> in
                guard let self = self else { return .just(.failure(ServerError(errorCode: .networkError))) }
                return self.repository.setMyGoals()
            }
            .map { [weak self] result -> MyGoalsVCState in
                switch result {
                case let .failure(serverError):
                    return .failure(serverError)
                case .success():
                    self?.router.nextViewTrigger?()
                    return .success
                }
            }.eraseToAnyPublisher()
        
        repository.reconfigCellsModel.sink(receiveValue: { [weak self] models in
            self?.reconfigCellModel.send(models)
        }).store(in: &cancellables)
            
        return Publishers.Merge4(loadingOutput, idleOutput, isSetAvailabelOutput, setMyGoalsOutput).removeDuplicates().eraseToAnyPublisher()
    }
}
