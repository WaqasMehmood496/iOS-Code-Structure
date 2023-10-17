//
//  AchievmentsVM.swift
//  Evexia
//
//  Created by Oleg Pogosian on 05.01.2022.
//

import Foundation
import Combine

class AchievmentsVM {
    
    lazy var isNeedShowStepsAchiv: Bool = {
        dailySteps >= 7_000
    }()
    
    var dataSource = CurrentValueSubject<[AchievmentsCellContentType], Never>([])
    
    var testTopModels = [
        TopAchievmentsModel(type: .steps, count: 10),
        TopAchievmentsModel(type: .daysIn, count: 22),
        TopAchievmentsModel(type: .prescribed, count: 12),
        TopAchievmentsModel(type: .completed, count: 123)]
    var testExploreModels = [
        ExploreAchivmentModel(descriptionText: "Number of badges collected for days where you have completed more than 7000 steps", imageName: "", isActive: true),
        ExploreAchivmentModel(descriptionText: "Completed 20 Daily Tasks", imageName: "activeTwentyAchieve", isActive: true),
        ExploreAchivmentModel(descriptionText: "Completed 50 Daily Tasks", imageName: "activeFiftyAchieve", isActive: true),
        ExploreAchivmentModel(descriptionText: "Completed 100 Daily Tasks", imageName: "activeHundredAchieve", isActive: true),
        ExploreAchivmentModel(descriptionText: "Completed 175 Daily Tasks", imageName: "activeHundredFiftyAchieve", isActive: true),
        ExploreAchivmentModel(descriptionText: "Completed 250 Daily Tasks", imageName: "activeTwoHundredAchieve", isActive: true),
        ExploreAchivmentModel(descriptionText: "Completed 365 Daily Tasks", imageName: "activeTwoHundredAchieve", isActive: true)]
    
    private var cancellables: [AnyCancellable] = []
    private let repository: AchievmentsRepositoryProtocol
    private let router: AchievmentsNavigation
    private let dailySteps: Int
    
    init(repository: AchievmentsRepositoryProtocol, router: AchievmentsNavigation, dailySteps: Int) {
        self.repository = repository
        self.router = router
        self.dailySteps = dailySteps
        self.binding()
    }
    
    func navigationToImpact() {
        router.navigationToImpact()
    }

    private func binding() {
        repository.dataSource
            .assign(to: \.value, on: self.dataSource)
            .store(in: &cancellables)
    }
}
