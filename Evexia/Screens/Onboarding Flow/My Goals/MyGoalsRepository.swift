//
//  MyGoalsRepository.swift
//  Evexia
//
//  Created by  Artem Klimov on 19.07.2021.
//

import Foundation
import Combine

protocol MyGoalsRepositoryProtocol {
    func getMyGoalsList() -> AnyPublisher<Result<[FocusSection], ServerError>, Never>
    func setMyGoals() -> AnyPublisher<Result<Void, ServerError>, Never>
    
    var selectionCounter: CurrentValueSubject<Int, Never> { get }
    var reconfigCellsModel: PassthroughSubject<[FocusSection], Never> { get }
}

class MyGoalsRepository {
    var selectionCounter = CurrentValueSubject<Int, Never>(0)
    var reconfigCellsModel = PassthroughSubject<[FocusSection], Never>()
    
    private var dataSource = CurrentValueSubject<[FocusSection], Never>([])
    private var onboardingNetworkProvider: OnboardingNetworkProviderProtocol
    private var cancellables = Set<AnyCancellable>()
    private var sectionModels: [FocusSection] = []
    private var sordetSection: [FocusSection] = []
    
    init(onboardingNetworkProvider: OnboardingNetworkProviderProtocol) {
        self.onboardingNetworkProvider = onboardingNetworkProvider
        reconfigSection()
    }
    
    private func bindSelection(for models: [MyGoalModel]) {
        Publishers.MergeMany(models.map { $0.isSelected })
            .sink { [weak self] _ in
                self?.selectionCounter.value = models.filter { $0.isSelected.value == true }.count
            }.store(in: &self.cancellables)
    }
    
    private func configSections(for models: [MyGoalModel]) -> Result<[FocusSection], ServerError> {
        let types = models.map { $0.type }
        let uniqueTypes = Array(Set(types))
        var sections = [FocusSection]()
        
        uniqueTypes.forEach({ type in
            let section = FocusSection(focus: type, goals: models.filter { $0.type == type })
            sections.append(section)
        })
        self.sectionModels = sections
        self.dataSource.send(sections)
        return .success(sections)
    }
    
    private func reconfigSection() {
        UserDefaults.$focusCard.sink(receiveValue: { [weak self] _ in
            guard let self = self, !self.sectionModels.isEmpty else { return }
            DispatchQueue.main.async {
                let sordetSection = self.sectionModels.sorted(by: { $0.focus < $1.focus })
                self.reconfigCellsModel.send(sordetSection)
            }
        }).store(in: &cancellables)
    }
    
    private func configSendModel() -> MyGoalsSendModel {
        
        let feel = self.dataSource.value.first(where: { $0.focus == .feel })?.goals.filter { $0.isSelected.value == true }.map { $0.id } ?? []
        let eat = self.dataSource.value.first(where: { $0.focus == .eat })?.goals.filter { $0.isSelected.value == true }.map { $0.id } ?? []
        let move = self.dataSource.value.first(where: { $0.focus == .move })?.goals.filter { $0.isSelected.value == true }.map { $0.id } ?? []
        let connect = self.dataSource.value.first(where: { $0.focus == .connect })?.goals.filter { $0.isSelected.value == true }.map { $0.id } ?? []

        let sendModel = MyGoalsSendModel(feel: feel, connect: connect, eat: eat, move: move)
        return sendModel
    }
}

extension MyGoalsRepository: MyGoalsRepositoryProtocol {
    
    func getMyGoalsList() -> AnyPublisher<Result<[FocusSection], ServerError>, Never> {
        return self.onboardingNetworkProvider.getMyGoalsList()
            .map({ [unowned self] responseModels -> Result<[FocusSection], ServerError> in
                let goalModels = responseModels.map { MyGoalModel(id: $0._id, title: $0.title, focus: $0.type) }
                self.bindSelection(for: goalModels)
                return self.configSections(for: goalModels)
            }).catch({ serverError -> AnyPublisher<Result<[FocusSection], ServerError>, Never> in
                return .just(.failure(serverError))
            })
            .eraseToAnyPublisher()
    }
    
    func setMyGoals() -> AnyPublisher<Result<Void, ServerError>, Never> {
        let sendModel = self.configSendModel()
        
        return self.onboardingNetworkProvider.setMyGoals(with: sendModel)
            .map { _ -> Result<Void, ServerError> in
                return .success(())
            }
            .catch { serverError -> AnyPublisher<Result<Void, ServerError>, Never> in
                return .just(.failure(serverError))
            }
            .eraseToAnyPublisher()
    }
}
