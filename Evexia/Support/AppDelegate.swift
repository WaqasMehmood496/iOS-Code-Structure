//
//  AppDelegate.swift
//  Evexia
//
//  Created by Yura Yatseyko on 22.06.2021.
//

import UIKit
import IQKeyboardManagerSwift
import Foundation
import Firebase
import FirebaseDynamicLinks
import FirebaseMessaging
import UserNotifications
import Swinject
import Combine
import RookSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Properties
    var window: UIWindow?
    private var dependenciesHolder: DependenciesHolder!
    private var deepLinkManager: DeepLinksManagerUseCaseProtocol!
    private var appCoordinator: RedirectService!
    private var rootViewController: UIViewController?
    private var notificationService: NotificationServiceUseCase!
    private var injector: Container!
    private var cancellables = Set<AnyCancellable>()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Rook Configuration:
        RookConnectConfigurationManager.shared.setConfiguration(
            clientUUID: "dcd46046-bc8f-406e-827f-cc30c7457833",
            secretKey: "LSGHFBCLtjsSw5Q26NDDma2WwFfgpB0eEyd8")
        RookConnectConfigurationManager.shared.setEnvironment(.sandbox)
        RookConnectConfigurationManager.shared.initRook()
        
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        self.dependenciesHolder = DependenciesHolder()
        self.injector = dependenciesHolder.injector()
        self.notificationService = injector.resolve(NotificationsService.self)!
        self.deepLinkManager = injector.resolve(DeepLinksManager.self)!
        self.appCoordinator = RedirectService(with: window, injector: injector, deepLinkManager: self.deepLinkManager)
        
        if let options = launchOptions {
            UIApplication.shared.registerForRemoteNotifications()
        }
        self.window?.rootViewController = SplashBuilder.build(injector: injector)
        self.window?.makeKeyAndVisible()
        
        self.configureGeneralUI()
        
        UIView.appearance().isExclusiveTouch = true
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let url = userActivity.webpageURL else {
            return false
        }
        let handled = self.deepLinkManager.handleUniversalLinks(from: url)
        return handled
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        notificationService.registerDevice(with: deviceToken)
        let tokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
        print("this will return '32 bytes' in iOS 13+ rather than the token \(tokenString)")
    }
    
    private func configureGeneralUI() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(CreateCommentVC.self)
        IQKeyboardManager.shared.disabledTouchResignedClasses.append(CreateCommentVC.self)
        IQKeyboardManager.shared.disabledTouchResignedClasses.append(CommentsListVC.self)
        
        self.window?.overrideUserInterfaceStyle = .light
        
        // Navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.setDefaultNavBar()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      
    }
}
