//
//  DiaryVM.swift
//  Evexia
//
//  Created by admin on 06.09.2021.
//

import Foundation
import Combine

enum DiaryMode: String {
    case normal
    case edit
}
    
final class DiaryVM {
    
    internal var selectedDate = CurrentValueSubject<Date, Never>(Date())
    internal var changedStatusTasks: [DayTasksModel] = []
    internal var dataSource = CurrentValueSubject<(model: [DayTasksModel], toDatePlan: Int), Never>(([], 0))
    internal var selectedDateTasks = CurrentValueSubject<[DiaryTaskCellModel], Never>([])
    internal var diaryMode = CurrentValueSubject<DiaryMode, Never>(.normal)
    internal var isSaveButtonAvailabel = CurrentValueSubject<Bool, Never>(false)
    internal var isShowAchivementView = PassthroughSubject<(Bool, AchievementViewType), Never>()
    internal var isFirstTaskCompleted = PassthroughSubject<(Bool, AchievementViewType), Never>()
    internal var isDailyTaskAward = PassthroughSubject<(Bool, AchievementViewType), Never>()

    private var router: DiaryRouter
    private var repository: DiaryRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private var healthStore: HealthStore
    
    init(router: DiaryRouter, repository: DiaryRepositoryProtocol, healthStore: HealthStore) {
        self.router = router
        self.repository = repository
        self.healthStore = healthStore
        self.binding()
    }
    
    private func binding() {
        self.repository.dataSource
            .assign(to: \.value, on: dataSource)
            .store(in: &self.cancellables)
        
        NotificationCenter.default.publisher(for: .availabilityUpdated)
            .sink(receiveValue: { [weak self] _ in
                self?.repository.getPlan()
            }).store(in: &cancellables)
            
        Publishers.CombineLatest3(self.selectedDate.compactMap { $0 }, self.dataSource.dropFirst(), self.diaryMode)
            .map { [unowned self] date, data, diaryMode in
                
                var calendar = Calendar.current
                calendar.timeZone = TimeZone.current
                
                if self.diaryMode.value == .edit {
                    self.selectedDateTasks.value.forEach { $0.isEditing.value = false }
                }
                let dateTasks = data.model.first(where: { calendar.startOfDay(for: Date(timeIntervalSince1970: $0.timestamp / 1_000)).compare(.isSameDay(as: date.toZeroTime())) })
                let returned = diaryMode == .normal ? dateTasks?.data.filter({ $0.isSelected.value == true }) : dateTasks?.data
                
                if self.diaryMode.value == .edit && date.compare(.isLater(than: Date().minus(days: 1))) {
                    returned?.forEach { $0.isEditing.value = true }
                }
                checkWhenPeriodPlanIsOver()
                
                return returned ?? []
            }
            .assign(to: \.value, on: selectedDateTasks)
            .store(in: &self.cancellables)
    }
    
    private func checkWhenPeriodPlanIsOver() {
        let allNotCompleteStatusTask = Set(dataSource.value.model.flatMap { $0.data.map { $0.status == .notCompleted } })
        let isShow = Date(timeIntervalSince1970: Double(dataSource.value.toDatePlan) / 1_000).compare(.isEarlier(than: Date()))
        let isNotDoneAllTasks = allNotCompleteStatusTask.contains(true) && allNotCompleteStatusTask.count == 1
        let randomIndex = Int.random(in: 1...2)
        let state: AchievementViewType = isNotDoneAllTasks ? .dontDonePersonalPlan : (randomIndex == 1 ? .donePersonalPlanOne : .donePersonalPlanTwo)
        
        isShowAchivementView.send((isShow, state))
    }
    
    internal func applyPerform(for model: DiaryTaskCellModel, action: TaskAction) {
        switch action {
        case .complete, .overComplite:
            self.completeTask(for: model, date: self.selectedDate.value)
        case .skipTask:
            self.skipTask(for: model, date: self.selectedDate.value)
        case .undo:
            self.undoTask(for: model, date: self.selectedDate.value)
        }
    }
    
    private func completeTask(for model: DiaryTaskCellModel, date: Date) {
        let dateNew = Calendar.current.startOfDay(for: Date(timeIntervalSince1970: model.timestamp / 1_000)).toZeroTime()

        self.repository.compliteTask(for: model, date: model.timestamp)
            .sink(receiveCompletion: { _ in
                return
            }, receiveValue: { [weak self] response in
                UserDefaults.countDailyTasks = response.data.dailyTasksReward.score
                
                if response.data.firstTaskCompleted {
                    self?.isFirstTaskCompleted.send((true, .doneFirst))
                    self?.isFirstTaskCompleted.send(completion: .finished)
                }
                
                // TODO: - show alert with get award
                if let isReceivedAward = response.data.dailyTasksReward.isReceivedAward, isReceivedAward {
                    self?.isDailyTaskAward.send((true, .doneFirst))
                    self?.isDailyTaskAward.send(completion: .finished)
                }
            })
            .store(in: &cancellables)
    }
    
    private func skipTask(for model: DiaryTaskCellModel, date: Date) {
        self.repository.skipTask(for: model, date: date)
    }
    
    private func undoTask(for model: DiaryTaskCellModel, date: Date) {
        self.repository.undoTask(for: model, date: date)
    }
    
    func getPlan() {
        self.repository.getPlan()
    }
    
    func updateSelectedTasks() {
        
        let selectedIDs = selectedDateTasks.value.filter { $0.isSelected.value == true }.map { $0.id }
        let requestModel = UpdateSelectedTaskRequestModel(timestamp: self.selectedDate.value.timeIntervalSince1970 * 1_000, tasks: selectedIDs)
        self.repository.updateSelectedtasks(with: requestModel)
    }
    
    internal func navigateToCalendar() {
        self.router.showDiaryCalendar(selectedDate: selectedDate)
    }
    
    func navigateToPersonalPlan() {
        router.navigateToPersonalPlan(profileFlow: .changePlanAfterEndPeriod)
    }
    
    func showDailyTaskAchivment(dailyTasks: Int) -> DailyTaskTypeAchivment? {
        repository.showDailyTaskAchivment(dailyTasks: dailyTasks)
    }
    
    func navigateToAchievementView() {
        self.router.navigateToAchievementScreen(steps: Int(healthStore.stepCount.value))
    }
}
