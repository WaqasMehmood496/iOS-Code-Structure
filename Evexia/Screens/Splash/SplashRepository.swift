//
//  SplashRepository.swift
//  Evexia
//
//  Created by admin on 02.05.2022.
//

import Foundation
import Combine

class SplashRepository {
     
    let userNetworkProvider: UserNetworkProviderProtocol
    
    init(userNetworkProvider: UserNetworkProviderProtocol) {
        self.userNetworkProvider = userNetworkProvider
    }
    
    func getUserProfile() -> AnyPublisher<User, ServerError> {
        return userNetworkProvider.getUserProfile()
    }
}
