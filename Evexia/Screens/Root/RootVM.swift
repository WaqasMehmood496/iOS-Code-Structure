//
//  RootVM.swift
//  Evexia Staging
//
//  Created by  Artem Klimov on 30.06.2021.
//

import Foundation
import Combine

class RootVM {
    
    // MARK: - Properties
    private let repository: RootRepositoryProtocol
    private var router: RootNavigation
    private var cancellables = Set<AnyCancellable>()
    internal var errorPublisher = PassthroughSubject<ServerError, Never>()
    private let healthStore: HealthStore

    init(router: RootNavigation, repository: RootRepositoryProtocol, healthStore: HealthStore) {
        self.router = router
        self.repository = repository
        self.healthStore = healthStore
        self.binding()
    }
    
    private func binding() {
        self.repository.deepLinkPresentedInfo
            .sink(receiveValue: { [weak self] model in
                switch model {
                case let .forgotPassword(token):
                    self?.router.navigateToSetPassword(token: token)
                case .pulseQuestionare:
                    self?.loadPulseSurvey()
                case .wellbeingQuestionare:
                    self?.loadWellbeingSurvey()
                default:
                    break
                }
            }).store(in: &cancellables)
        
        self.repository.notificationEvent
            .sink(receiveValue: { [weak self] event, id in
                switch event {
                case .wellbeingQuestionare:
                    self?.loadWellbeingSurvey()
                case .diary:
                    self?.router.select(.diary)
                case .dashBoard:
                    self?.router.select(.dashboard)
                case .pulseQuestionare:
                    self?.loadPulseSurvey()
                case .community:
                    self?.loadPost(id)
                case .achievement:
                    self?.showAchievement()
                }
            }).store(in: &cancellables)
    }
    
    func startSurvey(_ type: SurveyType?) {
        guard let surveyType = type else { return }
        
        switch surveyType {
        case .wellbeing:
            loadWellbeingSurvey()
        case .pulse:
            loadPulseSurvey()
        }
    }
    
    private func loadPulseSurvey() {
        self.repository.getPulse()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case let .failure(error):
                    self?.errorPublisher.send(error)
                case .finished:
                    return
                }
            }, receiveValue: { [weak self] questionnaireModel in
                self?.router.navigateToQuestionnaire(for: .pulse, model: questionnaireModel)
            }).store(in: &cancellables)
    }
    
    private func loadWellbeingSurvey() {
        self.repository.getWellbeing()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case let .failure(error):
                    self?.errorPublisher.send(error)
                case .finished:
                    return
                }
            }, receiveValue: { [weak self] questionnaireModel in
                self?.router.navigateToQuestionnaire(for: .wellbeing, model: questionnaireModel)
            }).store(in: &cancellables)
    }
    
    private func loadPost(_ id: String?) {
        guard let id = id else {
            navigateToCommunity()
            return
        }
        
        self.repository.loadPost(id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case let .failure(error):
                    self?.errorPublisher.send(error)
                case .finished:
                    return
                }
            }, receiveValue: { [weak self] response in
                guard let post = response.data.first else { return }
                let lPost = LocalPost(post: post)
                self?.router.navigateToPost(post: lPost)
            }).store(in: &cancellables)
    }
    
    private func showAchievement() {
        let steps: Int = Int(healthStore.stepCount.value)
        self.navigateToAchievements(steps: steps)
    }
    
    func navigateToAchievements(steps: Int) {
        self.router.navigateToAchievements(steps: steps)
    }
    
    func navigateToCommunity() {
        DispatchQueue.main.async {
            self.router.select(.community)
        }
    }
}
