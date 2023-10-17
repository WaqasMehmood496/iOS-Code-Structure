//
//  DeepLinksManager.swift
//  Evexia Staging
//
//  Created by  Artem Klimov on 21.07.2021.
//

import Foundation
import FirebaseDynamicLinks
import Combine

// MARK: - DeepLinksManager
class DeepLinksManager {
    
    // - Internal Properties
    var deepLinkPresentedInfo = CurrentValueSubject<DeepLinkModel?, Never>(nil)
    var deepLintPushNotificationPresented = PassthroughSubject<DeepLinkModel, Never>()
    
    func parseDeepLink(_ url: URL) -> DeepLinkModel? {
        guard let params = url.queryParameters else {
            parseDeepLink(with: url.paths)
            return nil
        }
        
        let linkType = DeepLinksKeys.allCases.compactMap { key -> DeepLinkModel? in
            if params.keys.contains(key.rawValue), let token = params["token"] {
                return key.generateDeepLinkModel(token: token)
            } else {
                return nil
            }
        }.compactMap({ $0 }).first
        
        return linkType
    }
    
    func parseDeepLink(with paths: [String: String]?) {
        guard let paths = paths?.filter { $0.key != "redirect" }, let keyPath = paths.compactMap({ $0.key }).last else { return }
        guard let linkType = DeepLinksKeys.allCases.compactMap({ key -> DeepLinkModel? in
            if keyPath == key.rawValue {
                return key.generateDeepLinkModel()
            } else {
                return nil
            }
        }).compactMap({ $0 }).first else { return }
        print(linkType)
        deepLinkPresentedInfo.send(linkType)
    }
}

// MARK: - DeepLinksManager: DeepLinksManagerUseCaseProtocol
extension DeepLinksManager: DeepLinksManagerUseCaseProtocol {
    
    func handleUniversalLinks(from url: URL) -> Bool {
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(url) { [weak self] dynamiclink, error in
            if let error = error {
                Log.error("handled in \(#function) with error: \(error.localizedDescription)")
            } else if let link = dynamiclink?.url {
                guard let deepLinkType = self?.parseDeepLink(link) else { return }
                self?.deepLinkPresentedInfo.send(deepLinkType)
            }
        }
        return handled
    }
    
    func handleUniversalLink(from url: URL) -> Bool {
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(url, completion: { _, _ in })
        return handled
    }
    
    func handleNotification(_ notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        if let data = userInfo["payload"] as? String {
            process(data: data)
        }
    }
    
    private func process(data: String) {
        
        switch data {
        case data where data == "DASHBOARD":
            deepLintPushNotificationPresented.send(.dashBoard)
        case data where data == "DIARY":
            deepLintPushNotificationPresented.send(.diary)
        case data where data == "QUESTIONARE":
            deepLinkPresentedInfo.send(.wellbeingQuestionare)
        default: break
        }
    }
}
