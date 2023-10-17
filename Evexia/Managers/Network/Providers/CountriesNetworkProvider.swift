//
//  CountriesNetworkProvider.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 29.07.2021.
//

import Foundation
import Combine

protocol CountriesNetworkProviderProtocol {
     
    func fetchCountries() -> AnyPublisher<[String], ServerError>
}

final class CountriesNetworkProvider: NetworkProvider, CountriesNetworkProviderProtocol {
    
    func fetchCountries() -> AnyPublisher<[String], ServerError> {
        return self.request(.countries)
            .eraseToAnyPublisher()
    }
}
