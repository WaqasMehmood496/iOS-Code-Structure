//
//  SetParameterRepository.swift
//  Evexia
//
//  Created by  Artem Klimov on 30.07.2021.
//

import Foundation
import Combine

protocol SetParameterRepositoryProtocol {
    func updateProfile(to model: UpdateProfileModel) -> AnyPublisher<User, ServerError>
    func updateWeight(to model: UpdateWeightModel) -> AnyPublisher<User, ServerError>
}

class SetParameterRepository {
    private var userNetworkProvider: UserNetworkProviderProtocol
    
    init(userNetworkProvider: UserNetworkProviderProtocol) {
        self.userNetworkProvider = userNetworkProvider
    }
}

extension SetParameterRepository: SetParameterRepositoryProtocol {
    func updateProfile(to model: UpdateProfileModel) -> AnyPublisher<User, ServerError> {
        return self.userNetworkProvider.updateProfile(with: model)
            .handleEvents(receiveOutput: { user in
                var user = user
                
                if !isMetricSystem {
                    let weight = user.weight.changeMeasurementSystem(unitType: .mass).value
                    let height = user.height.changeMeasurementSystem(unitType: .lengh).value
                    user.weight = weight
                    user.height = height
                }
                
                UserDefaults.userModel = user
            }).eraseToAnyPublisher()
    }
    
    func updateWeight(to model: UpdateWeightModel) -> AnyPublisher<User, ServerError> {
        self.userNetworkProvider.setWeight(to: model)
            .handleEvents(receiveOutput: { user in
                UserDefaults.lastStatisticUpdate = Date().timeIntervalSince1970
                var user = user
                if !isMetricSystem {
                    let weight = user.weight.changeMeasurementSystem(unitType: .mass).value
                    let height = user.height.changeMeasurementSystem(unitType: .lengh).value
                    user.weight = weight
                    user.height = height
                }
                UserDefaults.userModel = user
            }).eraseToAnyPublisher()
    }
}
