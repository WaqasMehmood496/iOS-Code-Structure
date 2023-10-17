//
//  DashboardVM.swift
//  Evexia
//
//  Created by admin on 11.09.2021.
//

import UIKit
import Combine

class DashboardVM {
    
    internal var curentFilterType = CurrentValueSubject<StatsDateType, Never>(.week)
    internal var intervalValue = CurrentValueSubject<String, Never>("")
    internal var dataSource = CurrentValueSubject<[DashboardSectionModel], Never>([])
    internal var errorPublisher = PassthroughSubject<ServerError, Never>()
    var breaksCount = 0
    
    private var router: DashboardNavigation
    private var repository: DashboardRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private var currentFilterDate: Date = Date().toZeroTime()
    private var startFilterDate: Date = Date()
    private var endFilterDate: Date = Date()
    
    init(router: DashboardNavigation, repository: DashboardRepositoryProtocol) {
        self.repository = repository
        self.router = router
        self.binding()
    }
    
    func subscribeOnFilterChanges() {
        self.curentFilterType
            .sink(receiveValue: { [weak self] value in
                self?.currentFilterDate = Date()
                switch value {
                case .week:
                    self?.getWeekStartFromCurrentDate()
                case .month:
                    self?.getMonthStartFromCurrentDate()
                case .year:
                    self?.getYearStartFromCurrentDate()
                default:
                    break
                }
                self?.retriveStatistic()
                self?.updateDistance()
            }).store(in: &cancellables)
    }
    
    private func binding() {
        Publishers.CombineLatest(
            Publishers.CombineLatest4(
                self.repository.surveySection, self.repository.progressSection, self.repository.moveProgressSection, self.repository.statisticSection),
            Publishers.CombineLatest4(
                self.repository.walkSection,
                self.repository.completedTasksSection,
                self.repository.sliderSection,
                self.repository.breaksCount))
            .map { surveys, progress in
                self.breaksCount = progress.3
                let sliderSection = DashboardSectionModel(title: .slider, data: [DashboardSectionDataType.slider(progress.2)])
                let surveySection = DashboardSectionModel(title: .survey, data: surveys.0?.compactMap { DashboardSectionDataType.survey($0) } ?? [] )
                let progressSection = DashboardSectionModel(title: .progress, data: [DashboardSectionDataType.progress(surveys.1)])
                let walkSection = DashboardSectionModel(title: .walk, data: [DashboardSectionDataType.walk(progress.0)])
                let moveSection = DashboardSectionModel(title: .moveProgress, data: [DashboardSectionDataType.moveProgress(surveys.2)], breaksCount: self.breaksCount)
                let completedTasks = DashboardSectionModel(title: .completedTasks, data: [DashboardSectionDataType.completedTasks(progress.1)], breaksCount: self.breaksCount)
                let statisticSection = DashboardSectionModel(title: .statistic, data: [DashboardSectionDataType.statistic(surveys.3)])
                
                var sections: [DashboardSectionModel]
                if UserDefaults.isShowAchieve {
                    sections = [surveySection, sliderSection, progressSection, walkSection, moveSection, completedTasks, statisticSection].compactMap { $0 }
                } else {
                    sections = [surveySection, progressSection, moveSection, statisticSection].compactMap { $0 }
                }
                return sections
            }
            .assign(to: \.value, on: self.dataSource)
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .surveyDone)
            .map { $0.object as? WellbeingScore }
            .sink(receiveValue: { [weak self] score in
                guard let self = self else { return }
                
                self.repository.getDashboard(fromDate: self.startFilterDate, toDate: self.endFilterDate, filterType: self.curentFilterType.value)
                guard let wellbeingScore = score else { return }
                self.router.navigateToQuestionnaireResult(for: wellbeingScore)
            }).store(in: &cancellables)
    }
    
    func redirect(with model: DeepLinkModel) {
        switch model {
        case .pulseQuestionare:
            self.startSurvey(.pulse)
        case .wellbeingQuestionare:
            self.startSurvey(.wellbeing)
        default:
            break
        }
    }
    
    func retriveStatistic() {
        self.repository.getDashboard(fromDate: startFilterDate, toDate: endFilterDate, filterType: curentFilterType.value)
    }
    
    func skipSurvey(_ model: SurveyModel?) {
        guard let survey = model else { return }
        switch survey.type {
        case .pulse:
            self.repository.skipPulseSurvey()
        case .wellbeing:
            self.repository.skipWellbeingSurvey()
        }
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
    
    func updateProgress() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            self.repository.getDashboard(fromDate: self.startFilterDate, toDate: self.endFilterDate, filterType: self.curentFilterType.value)
        }
    }
    
    func showPrevious() {
        switch self.curentFilterType.value {
        case .week:
            self.currentFilterDate = self.currentFilterDate.minus(days: 7)
            self.getWeekStartFromCurrentDate()
        case .month:
            self.currentFilterDate = self.currentFilterDate.minus(months: 1)
            self.getMonthStartFromCurrentDate()
        case .year:
            self.currentFilterDate = self.currentFilterDate.minus(years: 1)
            self.getYearStartFromCurrentDate()
        default:
            break
        }
        
        self.retriveStatistic()
        self.updateDistance()
    }
    
    func showNext() {
        switch self.curentFilterType.value {
        case .week:
            self.currentFilterDate = self.currentFilterDate.plus(days: 7)
            self.getWeekStartFromCurrentDate()
        case .month:
            self.currentFilterDate = self.currentFilterDate.plus(months: 1)
            self.getMonthStartFromCurrentDate()
        case .year:
            self.currentFilterDate = self.currentFilterDate.plus(years: 1)
            self.getYearStartFromCurrentDate()
        default:
            break
        }
        
        self.retriveStatistic()
        self.updateDistance()
    }
    
    private func getWeekStartFromCurrentDate() {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        calendar.firstWeekday = 2
        let components = calendar.dateComponents([.year, .weekOfYear, .yearForWeekOfYear], from: self.currentFilterDate)
        
        self.startFilterDate = calendar.startOfDay(for: calendar.date(from: components)!)
        self.endFilterDate = self.startFilterDate.plus(days: 6)
    }
    
    private func getMonthStartFromCurrentDate() {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        calendar.firstWeekday = 2
        
        let components = calendar.dateComponents([.year, .month], from: self.currentFilterDate)
        self.startFilterDate = calendar.startOfDay(for: calendar.date(from: components)!)
        self.endFilterDate = self.startFilterDate.plus(months: 1).minus(days: 1)
    }
    
    private func getYearStartFromCurrentDate() {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        calendar.firstWeekday = 2
        
        let components = calendar.dateComponents([.year], from: self.currentFilterDate)
        self.startFilterDate = calendar.startOfDay(for: calendar.date(from: components)!)
        self.endFilterDate = self.startFilterDate.plus(years: 1).minus(days: 1)
    }
    
    private func updateDistance() {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.current
        switch self.curentFilterType.value {
        case .week:
            let pattern = "dd MMMM yyyy"
            dateFormatter.dateFormat = pattern
            let startDate = dateFormatter.string(from: startFilterDate)
            let endDate = dateFormatter.string(from: endFilterDate)
            self.intervalValue.send(startDate + " - " + endDate)
        case .month:
            let pattern = "MMMM yyyy"
            dateFormatter.dateFormat = pattern
            let dateString = dateFormatter.string(from: currentFilterDate)
            self.intervalValue.send(dateString)
        case .year:
            let pattern = "yyyy"
            dateFormatter.dateFormat = pattern
            let dateString = dateFormatter.string(from: currentFilterDate)
            self.intervalValue.send(dateString)
        default:
            break
        }
    }
    
    func takeBreak(type: BreaksType) {
        self.repository.takeBreak(type: type)
    }
}
