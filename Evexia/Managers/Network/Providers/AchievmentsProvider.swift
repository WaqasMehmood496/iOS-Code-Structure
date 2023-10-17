//
//  AchievmentsProvider.swift
//  Evexia
//
//  Created by Oleg Pogosian on 25.01.2022.
//

import Foundation
import Combine

protocol AchievmentsNetworkProviderProtocol {
    
    /** Get All Achievements */
    func getAchievments() -> AnyPublisher<AchievmentsResponseModel, ServerError>
    
    /** Get Carbon Offset */
    func getCarbonOffset() -> AnyPublisher<CarboneResponseModel, ServerError>
    
}

class AchievmentsNetworkProvider: NetworkProvider, AchievmentsNetworkProviderProtocol {
    
    func getAchievments() -> AnyPublisher<AchievmentsResponseModel, ServerError> {
        return request(.getAchiev).eraseToAnyPublisher()
    }
    
    func getCarbonOffset() -> AnyPublisher<CarboneResponseModel, ServerError> {
        return request(.getCarboneOffset).eraseToAnyPublisher()
    }
    
}
