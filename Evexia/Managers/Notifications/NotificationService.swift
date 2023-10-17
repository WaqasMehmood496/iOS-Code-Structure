//
//  NotificationService.swift
//  Evexia
//
//  Created by admin on 20.10.2021.
//

import Foundation
import UserNotifications
import Combine
import Swinject
import FirebaseMessaging

// MARK: - NotificationServiceEventSubscriber
protocol NotificationServiceUseCase {
    func registerDevice(with apnsToken: Data?)
}

protocol NotificationServiceEventSubscriber {
    func registerForPushNotifications()
    
    var event: PassthroughSubject<(NotificationServiceEvent, String?), Never> { get set }
}

// MARK: - NotificationsService
final class NotificationsService: NSObject, NotificationServiceEventSubscriber {
    var event = PassthroughSubject<(NotificationServiceEvent, String?), Never>()
    
    private var injector: Container
    private var center: UNUserNotificationCenter
    
    init(injector: Container, center: UNUserNotificationCenter) {
        self.injector = injector
        self.center = center
        super.init()
        self.binding()
    }
    
    deinit {
        Log.info("NotificationsService deinix")
    }
    
    private func binding() {
        self.center.delegate = self
        Messaging.messaging().delegate = self
        self.registerForPushNotifications()
    }
    
    func handleNotificationResponse(userInfo: [AnyHashable: Any]) {
        guard let action = userInfo["action"] as? String,
              let actionType = NotificationActionType(rawValue: action),
              let event = userInfo["payload"] as? String
        else { return }
        switch actionType {
        case .openScreen:
            guard let payloadType = NotificationServiceEvent(rawValue: event) else { return }
            var communityID: String?
            if payloadType == .community {
                if let id = userInfo["postId"] as? String {
                    communityID = id
                }
            }
            self.event.send((payloadType, communityID))
        case .openQuestionnaire:
            guard let payloadType = NotificationServiceEvent(rawValue: event) else { return }
            self.event.send((payloadType, nil))
        }
    }
    
}

// MARK: NotificationsService: UNUserNotificationCenterDelegate
extension NotificationsService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        self.handleNotificationResponse(userInfo: userInfo)
        completionHandler()
    }
    
}

// MARK: - NotificationsService: NotificationsServiceProtocol
extension NotificationsService {
    
    func registerForPushNotifications() {
        center
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                guard granted else { return }
                UNUserNotificationCenter.current().getNotificationSettings { _ in
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
    }
}

extension NotificationsService: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let tokenDict = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: tokenDict)
        UserDefaults.firebaseCMToken = fcmToken
        UserDefaults.firebaseCMTokenStorage = fcmToken
    }
}

extension NotificationsService: NotificationServiceUseCase {
    func registerDevice(with apnsToken: Data?) {
        Messaging.messaging().apnsToken = apnsToken
        if let token = Messaging.messaging().fcmToken {
            UserDefaults.firebaseCMToken = token
            UserDefaults.firebaseCMTokenStorage = token
        }
    }
}
