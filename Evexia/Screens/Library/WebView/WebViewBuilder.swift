//
//  WebViewBuilder.swift
//  Evexia
//
//  Created by admin on 07.10.2021.
//

import Foundation

class WebViewBuilder {
    static func build(url: URL) -> WebViewVC {
        let vc = WebViewVC.board(name: .webView)
        let vm = WebViewVM(url: url)
        vc.viewModel = vm
        return vc
    }
}
