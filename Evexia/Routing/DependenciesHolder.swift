//
//  DependenciesHolder.swift
//  Evexia
//
//  Created by  Artem Klimov on 22.06.2021.
//

import Swinject
import Network

class DependenciesHolder {
    
    func injector() -> Container {
        let container = Container()
        
        container.register(NotificationsService.self) { _ -> NotificationsService in
            return NotificationsService(injector: container, center: UNUserNotificationCenter.current())
        }.inObjectScope(.container)
        
        container.register(NetworkMonitoringService.self) { _ -> NetworkMonitoringService in
            return NetworkMonitoringService()
        }.inObjectScope(.container)
        
        container.register(CommunityNetworkProvider.self) { resolver -> CommunityNetworkProvider in
            return CommunityNetworkProvider(networkMonitoringService: resolver.resolve(NetworkMonitoringService.self)!)
        }.inObjectScope(.transient)
        
        container.register(UserNetworkProvider.self) { resolver -> UserNetworkProvider in
            return UserNetworkProvider(networkMonitoringService: resolver.resolve(NetworkMonitoringService.self)!)
        }.inObjectScope(.transient)
        
        container.register(OnboardingNetworkProvider.self) { resolver -> OnboardingNetworkProvider in
            return OnboardingNetworkProvider(networkMonitoringService: resolver.resolve(NetworkMonitoringService.self)!)
        }.inObjectScope(.transient)
        
        container.register(CountriesNetworkProvider.self) { resolver -> CountriesNetworkProvider in
            return CountriesNetworkProvider(networkMonitoringService: resolver.resolve(NetworkMonitoringService.self)!)
        }.inObjectScope(.transient)

        container.register(BenefitsNetworkProvider.self) { resolver -> BenefitsNetworkProvider in
            return BenefitsNetworkProvider(networkMonitoringService: resolver.resolve(NetworkMonitoringService.self)!)
        }.inObjectScope(.transient)
        
        container.register(WellbeingNetworkProvider.self) { resolver -> WellbeingNetworkProvider in
            return WellbeingNetworkProvider(networkMonitoringService: resolver.resolve(NetworkMonitoringService.self)!)
        }.inObjectScope(.transient)
        
        container.register(DiaryNetworkProvider.self) { resolver -> DiaryNetworkProvider in
            return DiaryNetworkProvider(networkMonitoringService: resolver.resolve(NetworkMonitoringService.self)!)
        }.inObjectScope(.transient)
        
        container.register(DashboardNetworkProvider.self) { resolver -> DashboardNetworkProvider in
            return DashboardNetworkProvider(networkMonitoringService: resolver.resolve(NetworkMonitoringService.self)!)
        }.inObjectScope(.transient)
        
        container.register(LibraryNetworkProvider.self) { resolver -> LibraryNetworkProvider in
            return LibraryNetworkProvider(networkMonitoringService: resolver.resolve(NetworkMonitoringService.self)!)
        }.inObjectScope(.transient)
        
        container.register(QuestionnaireNetworkProvider.self) { resolver -> QuestionnaireNetworkProvider in
            return QuestionnaireNetworkProvider(networkMonitoringService: resolver.resolve(NetworkMonitoringService.self)!)
        }.inObjectScope(.transient)
        
        container.register(DeepLinksManager.self) { _ -> DeepLinksManager in
            return DeepLinksManager()
        }.inObjectScope(.container)
        
        container.register(HealthStore.self) { _ -> HealthStore in
            return HealthStore()
        }.inObjectScope(.transient)
        
        container.register(PersonalDevelopmentNetworkProvider.self) { resolver -> PersonalDevelopmentNetworkProvider in
            return PersonalDevelopmentNetworkProvider(networkMonitoringService: resolver.resolve(NetworkMonitoringService.self)!)
        }.inObjectScope(.transient)
        
        container.register(AchievmentsNetworkProvider.self) { resolver -> AchievmentsNetworkProvider in
            return AchievmentsNetworkProvider(networkMonitoringService: resolver.resolve(NetworkMonitoringService.self)!)
        }.inObjectScope(.transient)
        
        container.register(BiometricdService.self) { resolver -> BiometricdService in
            return BiometricdService()
        }.inObjectScope(.transient)
        
//        container.register(AchievmentsNetworkProvider.self) { resolver -> PersonalDevelopmentNetworkProvider in
//            return AchievmentsNetworkProvider(networkMonitoringService: resolver.resolve(NetworkMonitoringService.self)!)
//        }.inObjectScope(.transient)
        
        return container
    }
}
