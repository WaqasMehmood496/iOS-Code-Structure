//
//  DeepLinksManagerUseCaseProtocol.swift
//  Evexia
//
//  Created by  Artem Klimov on 21.07.2021.
//

import Foundation
import Combine
import FirebaseDynamicLinks

protocol DeepLinksManagerUseCaseProtocol {
    
    /**
     Presented info publisher for UI.
     */
    var deepLinkPresentedInfo: CurrentValueSubject<DeepLinkModel?, Never> { get set }
    
    /**
     Presented info publisher for UI from Push Notification
     */
    var deepLintPushNotificationPresented: PassthroughSubject<DeepLinkModel, Never> { get set }
    
    /**
     Will handle dynamic handle links received as Universal Links when the app is already installed.
     Call method in func application(_ application: UIApplication, continue userActivity: NSUserActivity,
     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
     */
    func handleUniversalLinks(from url: URL) -> Bool
    
    /**
     Will handle dynamic handle links received as Universal Links when the app is already installed.
     Cheking if app launch from deep link
     */
    func handleUniversalLink(from url: URL) -> Bool
    
    /**
     Will handle dynamic handle links received as notification when the app is already installed.
     Cheking if app launch from deep link
     */
    func handleNotification(_ notification: UNNotification)
}
