//
//  ExternalRepository.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 02.09.2021.
//

import Foundation
import Combine

// MARK: ExternalRepositoryProtocol
protocol ExternalRepositoryProtocol { }

// MARK: ExternalRepository
class ExternalRepository {
    
    private var userNetworkProvider: UserNetworkProviderProtocol
    
    init(userNetworkProvider: UserNetworkProviderProtocol) {
        self.userNetworkProvider = userNetworkProvider
    }
}

// MARK: ExternalRepository: ExternalRepositoryProtocol
extension ExternalRepository: ExternalRepositoryProtocol { }
