//
//  CountriesVM.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 29.07.2021.
//

import Foundation
import Combine

final class CountriesVM: CountriesVMType {
    
    // MARK: - Properties
    private let repository: CountriesRepositoryProtocol
    private var router: CountriesNavigation
    private var cancellables: [AnyCancellable] = []
    
    init(router: CountriesNavigation, repository: CountriesRepositoryProtocol) {
        self.repository = repository
        self.router = router
    }
    
    func transform(input: CountriesVMInput) -> CountriesVMOutput {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        let appearOutput = appearPublisher(for: input.appear)
        
        let setCountry = input.setCountry
            .receive(on: DispatchQueue.main)
            .flatMap({ [unowned self] country -> AnyPublisher<Result<User, ServerError>, Never> in
                UserDefaults.userModel?.country = country
                let model = UpdateProfileModel(userModel: UserDefaults.userModel!)
                return self.repository.updateProfile(to: model)
            })
            .receive(on: DispatchQueue.main)
            .map { [weak self] _ -> CountriesVCState in
                self?.router.closeView()
                return .idle
            }.eraseToAnyPublisher()
        
        return Publishers.Merge(appearOutput, setCountry).eraseToAnyPublisher()
    }
    
    private func appearPublisher(for appear: AnyPublisher<Void, Never>) -> CountriesVMOutput {
        return appear.flatMap {
            self.repository.retrieveCountries()
        }
        .receive(on: DispatchQueue.main)
        .map { result -> CountriesVCState in
            switch result {
            case let .failure(error):
                let serverError = error as? ServerError ?? ServerError(errorCode: .networkError)
                return .failure(serverError)
            case let .success(models):
                return .success(models)
            }
        }.eraseToAnyPublisher()
    }
    
    func closeView() {
        self.router.closeView()
    }
}
