//
//  ProfileEditRoute.swift
//  Evexia
//
//  Created by  Artem Klimov on 28.07.2021.
//

import Foundation

protocol ProfileEditRoute {

    var profileEditTransition: Transition { get }
    
    func showProfileEdit(profileFlow: ProfileEditScreenFlow)
}

extension ProfileEditRoute where Self: RouterProtocol {
    func showProfileEdit(profileFlow: ProfileEditScreenFlow) {
        let vc = ProfileEditBuilder.build(injector: self.injector, nextViewTrigger: {}, profileFlow: profileFlow)
        open(vc, transition: profileEditTransition)
    }
}
