//
//  CountriesRouter.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 29.07.2021.
//

import Foundation

// MARK: - CountriesRouterRoutes

protocol CountriesNavigation {
    func closeView()
}

class CountriesRouter: Router<CountriesVC>, CountriesNavigation {
    func closeView() {
        self.openTransition = PushTransition()
        self.close()
    }
}
