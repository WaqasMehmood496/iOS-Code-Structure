//
//  ExternalBuilder.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 01.09.2021.
//

import UIKit
import Combine
import Swinject

class ExternalBuilder {
    static func build(injector: Container, webViewType: WebViewType, dismissSocialWebView: PassthroughSubject<Int?, Never>) -> ExternalVC {
        let vc = ExternalVC.board(name: .external)
        let router = ExternalRouter(injector: injector)
        router.viewController = vc
        let repository = ExternalRepository(userNetworkProvider: injector.resolve(UserNetworkProvider.self)!)
        
        let externalVM = ExternalVM(
            webViewType: webViewType,
            router: router,
            repository: repository,
            dismissSocialWebView: dismissSocialWebView
        )
        
        vc.viewModel = externalVM

        return vc
    }
}
