//
//  SetParameterRouter.swift
//  Evexia
//
//  Created by  Artem Klimov on 30.07.2021.
//

import Foundation

protocol SetParameterNavigation {
    func closeView()
}

class SetParameterRouter: Router<SetParameterVC>, SetParameterNavigation {
    
    func closeView() {
        self.openTransition = PushTransition()
        self.close()
    }
}
