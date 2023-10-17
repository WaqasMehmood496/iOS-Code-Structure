//
//  LibraryBuilder.swift
//  Evexia
//
//  Created by admin on 24.09.2021.
//

import Foundation
import Swinject

class LibraryBuilder {
    static func build(injector: Container) -> LibraryVC {
        let vc = LibraryVC.board(name: .library)
        let router = LibraryRouter(injector: injector)
        router.viewController = vc
        let repository = LibraryRepository(libraryNetworkProvider: injector.resolve(LibraryNetworkProvider.self)!)
        let viewModel = LibraryVM(repository: repository, router: router)
        vc.viewModel = viewModel
        return vc
    }
}
