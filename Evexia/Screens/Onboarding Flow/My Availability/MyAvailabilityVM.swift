//
//  MyAvailabilityVM.swift
//  Evexia
//
//  Created by  Artem Klimov on 20.07.2021.
//

import Foundation
import Combine

class MyAvailabilityVM: MyAvailabilityVMType {
    
    // MARK: - Properties
    var profileFlow: ProfileEditScreenFlow
    private var router: MyAvailabilityNavigation
    private var repository: MyAvailabilityRepositoryProtocol
    
    var cancellables = Set<AnyCancellable>()
    
    init(router: MyAvailabilityNavigation, repository: MyAvailabilityRepositoryProtocol, profileFlow: ProfileEditScreenFlow) {
        self.router = router
        self.repository = repository
        self.profileFlow = profileFlow
    }
    
    func transform(input: MyAvailabilityVMInput) -> MyAvailabilityVMOuput {
        
        let durationOutput = self.repository.duration
            .map { duration -> MyAvailabilityVCState in
                return .getDuration(duration)
            }.eraseToAnyPublisher()
        
        let idleOutput = self.repository.dataSource
            .map({ models -> MyAvailabilityVCState in
                return .idle(models)
            }).eraseToAnyPublisher()
        
        let setAvailabilityOutput = input.setAvailability
            .flatMap({ [unowned self] _ -> AnyPublisher<Result<BaseResponse, ServerError>, Never> in
                return self.repository.setAvailability()
            })
            .receive(on: DispatchQueue.main)
            .map({ [weak self] result -> MyAvailabilityVCState in
                switch result {
                case let .failure(serverError):
                    return .failure(serverError)
                case .success:
                    switch self?.profileFlow {
                    case .onboarding:
                        self?.router.nextViewTrigger?()
                    case .edit:
                        NotificationCenter.default.post(name: .availabilityUpdated, object: nil)
                        self?.router.closeView()
                    case .changePlanAfterEndPeriod:
                        NotificationCenter.default.post(name: .availabilityUpdated, object: nil)
                        self?.router.showRoot()
                    default: break
                    }
                    
                    return .success
                }
            }).eraseToAnyPublisher()
        
        let setDuration = input.setDuration
            .map({ [weak self] duration -> MyAvailabilityVCState in
                self?.repository.setDuration(to: duration)
                return .success
            }).eraseToAnyPublisher()
        
        let isSetAvailable = self.repository.isAvailabilitySet
            .map { isAvailabel -> MyAvailabilityVCState in
                return .nextAvailabel(isAvailabel)
            }.eraseToAnyPublisher()
        
        return Publishers.Merge5(idleOutput, setAvailabilityOutput, isSetAvailable, durationOutput, setDuration).eraseToAnyPublisher()
    }
}
