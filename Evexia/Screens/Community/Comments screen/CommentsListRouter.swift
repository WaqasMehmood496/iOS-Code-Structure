//
//  CommentsListRouter.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 26.09.2021.
//

import Foundation
import Combine

// MARK: - CommentsListNavigation
protocol CommentsListNavigation {
    func openURL(url: URL, dismissSocialWebView: PassthroughSubject<Int?, Never>)
}

// MARK: - CommentsListRouter
class CommentsListRouter: Router<CommentsListVC>, CommentsListNavigation, ExternalRoute {
    var extenralTransition: Transition {
        return ModalTransitionWithNavigation(modalPresentationStyle: .automatic)
    }
    
    func openURL(url: URL, dismissSocialWebView: PassthroughSubject<Int?, Never>) {
        self.showExternal(webViewType: .url(url), dismissSocialWebView: dismissSocialWebView)
    }
}
