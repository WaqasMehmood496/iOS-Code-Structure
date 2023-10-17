//
//  PDCategoryDetailsBuilder.swift
//  Evexia Staging
//
//  Created by Oleg Pogosian on 09.12.2021.
//

import Foundation
import Swinject

final class PDCategoryDetailsBuilder {
    
    static func build(injector: Container, id: Int, title: String, isFavorite: Bool) -> PDCategoryDetailsVC {
        let vc = PDCategoryDetailsVC.board(name: .pdCategoryDetails)
        let router = PDCategoryDetailsRouter(injector: injector)
        router.viewController = vc
        let repository = PDCategoryDetailsRepository(pdNetworkProvider: injector.resolve(PersonalDevelopmentNetworkProvider.self)!, isFavorite: isFavorite)
        let viewModel = PDCategoryDetailsVM(repository: repository, router: router, id: id, title: title)
        vc.viewModel = viewModel
        return vc
    }
}
