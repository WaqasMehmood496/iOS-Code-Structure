//
//  PersonalPlanVM.swift
//  Evexia
//
//  Created by  Artem Klimov on 08.07.2021.
//

import Foundation
import Combine

class PersonalPlanVM: PersonalPlanVMType {
    
    private var router: PersonalPlanRouter
    private let repository: PersonalPlanRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    let errorPublisher = PassthroughSubject<ServerError, Never>()
    
    init(router: PersonalPlanRouter, repository: PersonalPlanRepositoryProtocol) {
        self.router = router
        self.repository = repository
    }
    
    func navigateToMyWhy() {
        self.router.nextViewTrigger?()
    }

    func setPersonalPlan(dict: [Int: Focus?]) {
        
        let personalPlan = PlanRequestModel(feel: (dict.key(forValue: .feel) ?? 0) + 1,
                                            eat: (dict.key(forValue: .eat) ?? 1) + 1,
                                            connect: (dict.key(forValue: .connect) ?? 2) + 1,
                                            move: (dict.key(forValue: .move) ?? 3) + 1)
        
        self.repository.setPersonalPlan(with: personalPlan)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case let .failure(serverError):
                    self?.errorPublisher.send(serverError)
                default:
                    break
                }
            }, receiveValue: { [weak self] _ in
                self?.navigateToMyWhy()
            }).store(in: &cancellables)
    }
}
