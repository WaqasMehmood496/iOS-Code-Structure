//
//  MyAvailabilityRoute.swift
//  Evexia
//
//  Created by  Artem Klimov on 20.07.2021.
//

import Foundation

protocol MyAvailabilityRoute {

    var myAvailabilityTransition: Transition { get }
    
    func showMyAvailability(profileFlow: ProfileEditScreenFlow)
}

extension MyAvailabilityRoute where Self: RouterProtocol {
    func showMyAvailability(profileFlow: ProfileEditScreenFlow) {
        let vc = MyAvailabilityBuilder.build(injector: self.injector, nextViewTrigger: nil, profileFlow: profileFlow)
        open(vc, transition: myAvailabilityTransition)
    }
}
