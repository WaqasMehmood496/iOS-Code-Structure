//
//  ProfileRouter.swift
//  Evexia
//
//  Created by  Artem Klimov on 28.07.2021.
//

import Foundation

typealias ProfileEditRoutes = SetParameterRoute & CountriesRoute & RootRoute & MyAvailabilityRoute

protocol ProfileEditNavigation: ProfileEditRoutes {
    func navigateToSetParameter(model: ProfileCellModel)
    func navigateToRoot()
    func navigateToMyAvailability()
}

class ProfileEditRouter: Router<ProfileEditVC>, ProfileEditNavigation {
    var myAvailabilityTransition: Transition {
        return PushTransition()
    }
    
    var rootTransition: Transition {
        return RootTransition(removeNavigation: true)
    }
    
    var countriesTransition: Transition {
        return PushTransition()
    }
    
    var setParameterTransition: Transition {
        return PushTransition()
    }
    
    func navigateToSetParameter(model: ProfileCellModel) {
        self.showSetParameter(model: model)
    }

    func navigateToCountries(model: ProfileCellModel) {
        self.showCountries(model: model)
    }
    
    func navigateToRoot() {
        self.showRoot()
    }
    
    func navigateToMyAvailability() {
        self.showMyAvailability(profileFlow: .edit)
    }
    
    deinit {
        Log.info("deinit -----> \(self)")
    }
}
