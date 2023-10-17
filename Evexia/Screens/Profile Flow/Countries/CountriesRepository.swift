//
//  CountriesRepository.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 29.07.2021.
//

import Foundation
import Combine

protocol CountriesRepositoryProtocol {
    
    func retrieveCountries() -> AnyPublisher<Result<[CountryCellModel], Error>, Never>
    func updateProfile(to model: UpdateProfileModel) -> AnyPublisher<Result<User, ServerError>, Never>
}

final class CountriesRepository {
    
    private var countriesNetworkProvider: CountriesNetworkProviderProtocol
    private var userNetworkProvider: UserNetworkProviderProtocol
    
    init(countriesNetworkProvider: CountriesNetworkProviderProtocol, userNetworkProvider: UserNetworkProviderProtocol) {
        self.countriesNetworkProvider = countriesNetworkProvider
        self.userNetworkProvider = userNetworkProvider
    }
    
}

extension CountriesRepository: CountriesRepositoryProtocol {
    
    func updateProfile(to model: UpdateProfileModel) -> AnyPublisher<Result<User, ServerError>, Never> {
        return self.userNetworkProvider.updateProfile(with: model)
            .map { response -> Result<User, ServerError> in
                return .success(response)
            }
            .catch { error -> AnyPublisher<Result<User, ServerError>, Never> in
                return .just(.failure(error))
            }
            .eraseToAnyPublisher()
    }
    
    func retrieveCountries() -> AnyPublisher<Result<[CountryCellModel], Error>, Never> {
        return countriesNetworkProvider.fetchCountries()
            .map { response -> Result<[CountryCellModel], Error> in
                
                let selected = UserDefaults.userModel?.country
                let models = response.sorted().map { CountryCellModel(country: $0, isSelected: selected == $0) }
               return .success(models)
            }
            .catch { error -> AnyPublisher<Result<[CountryCellModel], Error>, Never> in
                return .just(.failure(error))
            }
            .eraseToAnyPublisher()
    }
}
