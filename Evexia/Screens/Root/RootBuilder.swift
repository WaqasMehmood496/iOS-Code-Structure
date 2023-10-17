//
//  RootBuilder.swift
//  Evexia Staging
//
//  Created by  Artem Klimov on 30.06.2021.
//

import Foundation
import Swinject
import UIKit

final class RootBuilder {
    static func build(injector: Container) -> RootVC {
        let tabBarController = RootVC.board(name: .root)
        let router = RootRouter(injector: injector)
        router.viewController = tabBarController
        let repository = RootRepository(deepLinkService: injector.resolve(DeepLinksManager.self)!,
                                        notificationServiceEventSubscriber: injector.resolve(NotificationsService.self)!,
                                        questionnaireNetworkProvider: injector.resolve(QuestionnaireNetworkProvider.self)!,
                                        communityNetworkProvider: injector.resolve(CommunityNetworkProvider.self)!)

        let rootVM = RootVM(router: router, repository: repository, healthStore: injector.resolve(HealthStore.self)!)
        tabBarController.viewModel = rootVM
        
        let profile = UINavigationController(rootViewController: ProfileBuilder.build(injector: injector))
        let profileTabBarItem = UITabBarItem(title: "", image: UIImage(named: "profile"), selectedImage: UIImage(named: "profile"))
        profile.tabBarItem = profileTabBarItem
        let diary = UINavigationController(rootViewController: DiaryBuilder.build(router: DiaryRouter(injector: injector)))
           
        let diaryTabBarItem = UITabBarItem(title: "", image: UIImage(named: "diary"), selectedImage: UIImage(named: "diary"))
        diary.tabBarItem = diaryTabBarItem
        
        let dashboard = UINavigationController(rootViewController: DashboardBuilder.build(injector: injector))
        let dashboardTabBarItem = UITabBarItem(title: "", image: UIImage(named: "dashboard"), selectedImage: UIImage(named: "dashboard"))
        dashboard.tabBarItem = dashboardTabBarItem
        
        let community = UINavigationController(rootViewController: СommunityBuilder.build(injector: injector))
        let communityTabBarItem = UITabBarItem(title: "", image: UIImage(named: "community"), selectedImage: UIImage(named: "community"))
        community.tabBarItem = communityTabBarItem
        
        let library = UINavigationController(rootViewController: LibraryBuilder.build(injector: injector))
        let libraryTabBarItem = UITabBarItem(title: "", image: UIImage(named: "library"), selectedImage: UIImage(named: "library"))
        library.tabBarItem = libraryTabBarItem
        
        tabBarController.setViewControllers([profile, diary, dashboard, community, library], animated: false)
        tabBarController.customizeBackButton()
        return tabBarController
    }
}
