//
//  PDCategoryDetailsRoute.swift
//  Evexia Staging
//
//  Created by Oleg Pogosian on 09.12.2021.
//

import Foundation

protocol PDCategoryDetailsRoute {
    
    var pdTransition: Transition { get }
    
    func showCategoryWith(id: Int, title: String)
}

extension PDCategoryDetailsRoute where Self: RouterProtocol {
    func showCategoryWith(id: Int, title: String) {
        let vc = PDCategoryDetailsBuilder.build(injector: self.injector, id: id, title: title, isFavorite: id == -1)
        open(vc, transition: pdTransition)
    }
}
