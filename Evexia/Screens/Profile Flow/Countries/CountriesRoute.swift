//
//  CountriesRoute.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 29.07.2021.
//

import Foundation

protocol CountriesRoute {
    
    var countriesTransition: Transition { get }
    
    func showCountries(model: ProfileCellModel)
}

extension CountriesRoute where Self: RouterProtocol {
    func showCountries(model: ProfileCellModel) {
        let vc = CountriesBuilder.build(injector: self.injector)
        open(vc, transition: self.countriesTransition)
    }
}
