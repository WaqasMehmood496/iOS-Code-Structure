//
//  RootRepository.swift
//  Evexia
//
//  Created by  Artem Klimov on 30.06.2021.
//

import Foundation
import Combine

protocol RootRepositoryProtocol {
    var deepLinkPresentedInfo: PassthroughSubject<DeepLinkModel, Never> { get set }
    var notificationEvent: PassthroughSubject<(NotificationServiceEvent, String?), Never> { get set }
    
    func getPulse() -> AnyPublisher<QuestionnaireModel, ServerError>
    func getWellbeing() -> AnyPublisher<QuestionnaireModel, ServerError>
    func loadPost(_ id: String) -> AnyPublisher<PostData, ServerError>
}

class RootRepository {
    
    var deepLinkPresentedInfo = PassthroughSubject<DeepLinkModel, Never>()
    var notificationEvent = PassthroughSubject<(NotificationServiceEvent, String?), Never>()

    private var deepLinkService: DeepLinksManager
    private var notificationServiceEventSubscriber: NotificationServiceEventSubscriber
    private var cancellables = Set<AnyCancellable>()
    private var questionnaireNetworkProvider: QuestionnaireNetworkProviderProtocol
    private var communityNetworkProvider: CommunityNetworkProviderProtocol

    init(deepLinkService: DeepLinksManager, notificationServiceEventSubscriber: NotificationServiceEventSubscriber, questionnaireNetworkProvider: QuestionnaireNetworkProviderProtocol, communityNetworkProvider: CommunityNetworkProviderProtocol) {
        self.deepLinkService = deepLinkService
        self.notificationServiceEventSubscriber = notificationServiceEventSubscriber
        self.questionnaireNetworkProvider = questionnaireNetworkProvider
        self.communityNetworkProvider = communityNetworkProvider
        self.binding()
    }
    
    private func binding() {
        self.deepLinkService.deepLinkPresentedInfo
            .delay(for: 1, scheduler: RunLoop.main)
            .sink(receiveValue: { [weak self] info in
                guard let link = info else { return }
                self?.deepLinkPresentedInfo.send(link)
            }).store(in: &cancellables)
            
        self.notificationServiceEventSubscriber.event
            .delay(for: 1, scheduler: RunLoop.main)
            .sink(receiveValue: { [weak self] event, id in
                self?.notificationEvent.send((event, id))
            }).store(in: &cancellables)
        
        notificationServiceEventSubscriber.registerForPushNotifications()
    }
}

// MARK: RootRepository: RootRepositoryProtocol
extension RootRepository: RootRepositoryProtocol {
    func loadPost(_ id: String) -> AnyPublisher<PostData, ServerError> {
        return communityNetworkProvider.getPost(id)
    }

    func getPulse() -> AnyPublisher<QuestionnaireModel, ServerError> {
        return self.questionnaireNetworkProvider.getPulse()
    }
    
    func getWellbeing() -> AnyPublisher<QuestionnaireModel, ServerError> {
        return self.questionnaireNetworkProvider.getWellbeing()
    }
}
