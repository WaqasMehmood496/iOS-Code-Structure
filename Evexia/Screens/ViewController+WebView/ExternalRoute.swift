//
//  ExternalRoute.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 01.09.2021.
//

import Foundation
import Combine

protocol ExternalRoute {
    var extenralTransition: Transition { get }
    
    func showExternal(webViewType: WebViewType, dismissSocialWebView: PassthroughSubject<Int?, Never>)
}

extension ExternalRoute where Self: RouterProtocol {
    func showExternal(webViewType: WebViewType, dismissSocialWebView: PassthroughSubject<Int?, Never>) {
        let vc = ExternalBuilder.build(injector: injector, webViewType: webViewType, dismissSocialWebView: dismissSocialWebView)
        open(vc, transition: extenralTransition)
    }
}
