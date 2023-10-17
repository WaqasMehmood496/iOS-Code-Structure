//
//  LibraryRouter.swift
//  Evexia
//
//  Created by admin on 06.10.2021.
//

import Foundation
import AVKit

class LibraryRouter: Router<LibraryVC> {
    
    func showVideo(controller: AVPlayerViewController, completion: @escaping (() -> Void)) {
        self.viewController?.present(controller, animated: true, completion: {
            completion()
        })
    }
    
    func showPDF(url: String) {
        guard let url = URL(string: url) else { return }
        let webView = WebViewBuilder.build(url: url)
        self.viewController?.present(webView, animated: true, completion: nil)
    }
    
    func openBrowser(url: String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url)
    }
}
