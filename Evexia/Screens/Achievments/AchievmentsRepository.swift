//
//  AchievmentsRepository.swift
//  Evexia
//
//  Created by Oleg Pogosian on 05.01.2022.
//

import Foundation
import Combine
import UIKit

protocol AchievmentsRepositoryProtocol {
    var dataSource: CurrentValueSubject<[AchievmentsCellContentType], Never> { get set }
}

class AchievmentsRepository {
    
    var dataSource = CurrentValueSubject<[AchievmentsCellContentType], Never>([])
    
    private var achievmentsNetworkProvider: AchievmentsNetworkProviderProtocol
    private var cancellables = Set<AnyCancellable>()
    private var testTopModels: [TopAchievmentsModel] = []
    private var testExploreModels: [ExploreAchivmentModel] = []
    
    init(achievmentsNetworkProvider: AchievmentsNetworkProviderProtocol) {
        self.achievmentsNetworkProvider = achievmentsNetworkProvider
        self.getAchievs()
    }
    
    func generateDataSource() {
        Publishers.CombineLatest(getDevices(), getDevices())
            .map { settings, profile in
                return [.topAchiev(content: self.testTopModels), .impact, .exploreAchiev(content: self.testExploreModels),
                        .steps,
                        .exploreAchiev20,
                        .exploreAchiev50,
                        .exploreAchiev100,
                        .exploreAchiev175,
                        .exploreAchiev365
                ]
            }.assign(to: \.value, on: self.dataSource)
            .store(in: &self.cancellables)
    }
    
    func getDevices() -> AnyPublisher<AchievmentsCellContentType, Never> {
        return .just(.topAchiev(content: self.testTopModels))
    }
    
    func getAchievs() {
        achievmentsNetworkProvider.getAchievments()
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] response in
                self?.testTopModels = [
                    TopAchievmentsModel(type: .steps, count: response.daysAbove7KSteps),
                    TopAchievmentsModel(type: .daysIn, count: response.daysInTheApp),
                    TopAchievmentsModel(type: .prescribed, count: response.dailyTasksPrescribed),
                    TopAchievmentsModel(type: .completed, count: response.dailyTasksCompleted)]
                
                self?.testExploreModels = [
                    ExploreAchivmentModel(descriptionText: "Number of badges\ncollected for days where\nyou have completed more\nthan 7000 steps", imageName: "", count: response.stepsBadges, isActive: true),
                    ExploreAchivmentModel(descriptionText: "Completed 20 Daily Tasks", imageName: response.icons.icon20, count: nil, isActive: response.dailyTasksCompleted >= 20),
                    ExploreAchivmentModel(descriptionText: "Completed 50 Daily Tasks", imageName: response.icons.icon50, count: nil, isActive: response.dailyTasksCompleted >= 50),
                    ExploreAchivmentModel(descriptionText: "Completed 100 Daily Tasks", imageName: response.icons.icon100, count: nil, isActive: response.dailyTasksCompleted >= 100),
                    ExploreAchivmentModel(descriptionText: "Completed 175 Daily Tasks", imageName: response.icons.icon175, count: nil, isActive: response.dailyTasksCompleted >= 175),
                    ExploreAchivmentModel(descriptionText: "Completed 250 Daily Tasks", imageName: response.icons.icon250, count: nil, isActive: response.dailyTasksCompleted >= 250),
                    ExploreAchivmentModel(descriptionText: "Completed 365 Daily Tasks", imageName: response.icons.icon365, count: nil, isActive: response.dailyTasksCompleted >= 365)]
                
                self?.generateDataSource()
            }).store(in: &cancellables)
    }
}

extension AchievmentsRepository: AchievmentsRepositoryProtocol {
    
}
