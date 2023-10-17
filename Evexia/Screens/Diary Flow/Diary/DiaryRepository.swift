//
//  DiaryRepository.swift
//  Evexia
//
//  Created by admin on 06.09.2021.
//

import Foundation
import Combine

// MARK: - DiaryRepositoryProtocol
protocol DiaryRepositoryProtocol {
    
    var dataSource: CurrentValueSubject<(model: [DayTasksModel], toDatePlan: Int), Never> { get }
    
    func compliteTask(for model: DiaryTaskCellModel, date: Double) -> AnyPublisher<CompleteTaskResponseModel, ServerError>
    func skipTask(for model: DiaryTaskCellModel, date: Date)
    func undoTask(for model: DiaryTaskCellModel, date: Date)
    func updateSelectedtasks(with model: UpdateSelectedTaskRequestModel)
    func getPlan()
    func showDailyTaskAchivment(dailyTasks: Int) -> DailyTaskTypeAchivment?
}

// MARK: - DiaryRepository
final class DiaryRepository {
    internal var dataSource = CurrentValueSubject<(model: [DayTasksModel], toDatePlan: Int), Never>(([], 0))

    private let diaryNetworkProvider: DiaryNetworkProviderProtocol
    private var cancellables = Set<AnyCancellable>()

    init(diaryNetworkProvider: DiaryNetworkProviderProtocol) {
        self.diaryNetworkProvider = diaryNetworkProvider
    }
    
    private func removeTask(_ task: DiaryTaskCellModel) {
        let tasks = dataSource.value.model
        let dayTasks = tasks.first(where: { $0.timestamp == task.timestamp })
        dayTasks?.data.removeAll(where: { $0.id == task.id })
        tasks.first(where: { $0.timestamp == task.timestamp })?.data = dayTasks!.data
        self.dataSource.value.model = tasks
    }
    
    private func appendTask(_ task: DiaryTaskCellModel) {
        let tasks = dataSource.value.model

        let dayTasks = tasks.first(where: { $0.timestamp == task.timestamp })
        dayTasks?.data.append(task)
        tasks.first(where: { $0.timestamp == task.timestamp })?.data = dayTasks!.data
        self.dataSource.value.model = tasks

    }
}

// MARK: - DiaryRepository: DiaryRepositoryProtocol
extension DiaryRepository: DiaryRepositoryProtocol {

    func getPlan() {
        let requestModel = DiaryRequestModel(from: 1.0,
                                             to: 9_999_999_999_999_999.0)
        
    self.diaryNetworkProvider.getDiary(for: requestModel)
        .sink(receiveCompletion: { _ in
            return
        }, receiveValue: { [weak self] response in
            guard let diary = response.data.diary else { return }
            let models = diary.map { DayTasksModel(timestamp: $0.timestamp, data: $0.data) }
            self?.dataSource.send((models, response.data.toDate))
        }).store(in: &cancellables)
    }
    
    func compliteTask(for model: DiaryTaskCellModel, date: Double) -> AnyPublisher<CompleteTaskResponseModel, ServerError> {
        
        let requestModel = CompliteTaskRequestModel(timestamp: date, taskId: model.id)
        return self.diaryNetworkProvider.compliteTask(for: requestModel)
    }
    
    func skipTask(for model: DiaryTaskCellModel, date: Date) {
        let requestModel = TaskRequestModel(timestamp: model.timestamp, taskId: model.id)
        
        self.diaryNetworkProvider.skipTask(for: requestModel)
            .sink(receiveCompletion: { [weak self] _ in
                self?.removeTask(model)
            }, receiveValue: { [weak self] task in
                guard let newTask = task.data else { return }
                let new = DiaryTaskCellModel(timestamp: model.timestamp, id: newTask.id, description: newTask.title, focus: newTask.type, periodic: newTask.frequency, status: newTask.status, isSelected: newTask.selected!)
                self?.appendTask(new)
            })
            .store(in: &cancellables)
    }
    
    func undoTask(for model: DiaryTaskCellModel, date: Date) {
        let model = TaskRequestModel(timestamp: model.timestamp, taskId: model.id)
        self.diaryNetworkProvider.undoTask(for: model)
            .sink(receiveCompletion: { _ in
                return
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    func updateSelectedtasks(with model: UpdateSelectedTaskRequestModel) {
        
        self.diaryNetworkProvider.updateSelectedtasks(with: model)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    func showDailyTaskAchivment(dailyTasks: Int) -> DailyTaskTypeAchivment? {
        switch dailyTasks {
        case 20:
            return .complete20
        case 50:
            return .complete50
        case 100:
            return .complete100
        case 150:
            return .complete150
        case 200:
            return .complete200
        case 365:
            return .complete365
        default:
            return nil
        }
    }
}

class DayTasksModel {
    var timestamp: Double
    var data: [DiaryTaskCellModel]
    
    init(timestamp: Double, data: [TaskResponseModel]) {
        self.timestamp = timestamp
        self.data = data.compactMap { DiaryTaskCellModel(timestamp: timestamp, id: $0.id, description: $0.title, focus: $0.type, periodic: $0.frequency, status: $0.status, isSelected: $0.selected ?? true) }
    }
}
