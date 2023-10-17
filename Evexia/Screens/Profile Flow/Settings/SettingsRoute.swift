//
//  SettingsRoute.swift
//  Evexia
//
//  Created by  Artem Klimov on 20.08.2021.
//

import Foundation

protocol SettingsRoute {

    var settingsTransition: Transition { get }
    
    func showSettings()
}

extension SettingsRoute where Self: RouterProtocol {
    func showSettings() {
        let vc = SettingsBuilder.build(injector: self.injector)
        open(vc, transition: settingsTransition)
    }
}
