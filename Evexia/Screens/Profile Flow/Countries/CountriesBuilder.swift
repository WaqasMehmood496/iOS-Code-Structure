//
//  CountriesBuilder.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 29.07.2021.
//

import Foundation
import Swinject

final class CountriesBuilder {
    
    static func build(injector: Container) -> CountriesVC {
        let vc = CountriesVC.board(name: .countries)
        let repository = CountriesRepository(countriesNetworkProvider: injector.resolve(CountriesNetworkProvider.self)!, userNetworkProvider: injector.resolve(UserNetworkProvider.self)!)
        let router = CountriesRouter(injector: injector)
        router.viewController = vc
        let viewModel = CountriesVM(router: router, repository: repository)
        vc.viewModel = viewModel
        return vc
    }
}
