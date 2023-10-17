//
//  DashboardRepository.swift
//  Evexia
//
//  Created by admin on 12.09.2021.
//

import UIKit
import Combine

protocol DashboardRepositoryProtocol {
    var surveySection: CurrentValueSubject<[SurveyModel]?, Never> { get }
    var progressSection: CurrentValueSubject<WeekStatistic?, Never> { get }
    var moveProgressSection: CurrentValueSubject<[Stats]?, Never> { get }
    var statisticSection: CurrentValueSubject<[WeelbeingStatisticModel]?, Never> { get }
    var walkSection: CurrentValueSubject<StepsClass?, Never> { get }
    var completedTasksSection: CurrentValueSubject<StepsClass?, Never> { get }
    var sliderSection: CurrentValueSubject<[BadgeSliderModel]?, Never> { get }
    var breaksCount: CurrentValueSubject<Int, Never> { get }
    
    func getAllStatistic(fromDate: Date, toDate: Date, filterType: StatsDateType)
    func skipPulseSurvey()
    func skipWellbeingSurvey()
    func getWeekStatistic()
    func getPulse() -> AnyPublisher<QuestionnaireModel, ServerError>
    func getWellbeing() -> AnyPublisher<QuestionnaireModel, ServerError>
    func getDashboard(fromDate: Date, toDate: Date, filterType: StatsDateType)
    func takeBreak(type: BreaksType)
}

class DashboardRepository {
    
    var surveySection = CurrentValueSubject<[SurveyModel]?, Never>(nil)
    var progressSection = CurrentValueSubject<WeekStatistic?, Never>(nil)
    var moveProgressSection = CurrentValueSubject<[Stats]?, Never>(nil)
    var statisticSection = CurrentValueSubject<[WeelbeingStatisticModel]?, Never>(nil)
    var walkSection = CurrentValueSubject<StepsClass?, Never>(nil)
    var completedTasksSection = CurrentValueSubject<StepsClass?, Never>(nil)
    var sliderSection = CurrentValueSubject<[BadgeSliderModel]?, Never>(nil)
    var breaksCount = CurrentValueSubject<Int, Never>(0)
    
    private var dashboardNetworkProvider: DashboardNetworkProviderProtocol
    private var healthStore: HealthStore
    private var surveysData = [SurveyModel]()
    private var cancellables = Set<AnyCancellable>()
    private var questionnaireNetworkProvider: QuestionnaireNetworkProviderProtocol
    
    init(dashboardNetworkProvider: DashboardNetworkProviderProtocol, healthStore: HealthStore, questionnaireNetworkProvider: QuestionnaireNetworkProviderProtocol) {
        self.dashboardNetworkProvider = dashboardNetworkProvider
        self.healthStore = healthStore
        self.questionnaireNetworkProvider = questionnaireNetworkProvider
        self.getMoveStatistic()
    }
    
    deinit {
        Log.info("deinit -> \(self)")
    }
    
    private func getMonthDates(for date: Date) -> String {
     
        var calendar = Calendar.current
        calendar.locale = .current

        let interval = calendar.dateInterval(of: .month, for: date)!

        let days = calendar.dateComponents([.day], from: interval.start, to: interval.end).day!
        return String(days)
    }
}

extension DashboardRepository: DashboardRepositoryProtocol {
    
    func getPulse() -> AnyPublisher<QuestionnaireModel, ServerError> {
        return self.questionnaireNetworkProvider.getPulse()
    }
    
    func getWellbeing() -> AnyPublisher<QuestionnaireModel, ServerError> {
        return self.questionnaireNetworkProvider.getWellbeing()
    }
    
    func skipPulseSurvey() {
        self.dashboardNetworkProvider.skipPulse()
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [unowned self] _ in
                    self.surveysData.removeAll(where: { $0.type == .pulse })
                    self.surveySection.send(self.surveysData)
                  }).store(in: &cancellables)
    }
    
    func skipWellbeingSurvey() {
        self.dashboardNetworkProvider.skipWellbeing()
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [unowned self] _ in
                    self.surveysData.removeAll(where: { $0.type == .wellbeing })
                    self.surveySection.send(self.surveysData)
                  }).store(in: &cancellables)
        
    }
    
    func getWeekStatistic() {
        self.dashboardNetworkProvider.getWeekStatistic()
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .sink(receiveCompletion: {_ in
            }, receiveValue: { [unowned self] response in
                self.progressSection.send(response.statistic)
                
                if !response.wellbeingSurvey.isSkipped && response.wellbeingSurvey.isExist {
                    let surveyModel = SurveyModel(survey: response.wellbeingSurvey, type: .wellbeing)
                    
                    if !self.surveysData.contains(surveyModel) {
                        self.surveysData.append(surveyModel)
                    }
                } else {
                    self.surveysData.removeAll(where: { $0.type == .wellbeing })
                }
                
                if !response.pulseSurvey.isSkipped && response.pulseSurvey.isExist {
                    let surveyModel = SurveyModel(survey: response.pulseSurvey, type: .pulse)

                    if !self.surveysData.contains(surveyModel) {
                        self.surveysData.append(surveyModel)
                    }
                } else {
                    self.surveysData.removeAll(where: { $0.type == .pulse })
                }
                self.surveySection.send(self.surveysData)
            }).store(in: &cancellables)
    }
    
    func getAllStatistic(fromDate: Date, toDate: Date, filterType: StatsDateType) {
        let model = StatsRequestModel(type: filterType.value, dateFrom: fromDate.timeMillis, dateTo: toDate.timeMillis)
        self.dashboardNetworkProvider.getAllStatistic(model: model)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [unowned self] models in
                if filterType == .month {
                    self.generateMonthStatistic(fromDate: fromDate, toDate: toDate, for: models)
                } else {
                    let statModels = models.map { WeelbeingStatisticModel(model: $0) }
                    self.generateEmptyValues(fromDate: fromDate, toDate: toDate, models: statModels, filterType: filterType)
                }
            }).store(in: &cancellables)
    }
    
    func getDashboard(fromDate: Date, toDate: Date, filterType: StatsDateType) {
        let model = StatsRequestModel(type: filterType.value, dateFrom: fromDate.timeMillis, dateTo: toDate.timeMillis)
        self.dashboardNetworkProvider.getDashboard(model: model).sink { _ in
    
        } receiveValue: { [unowned self] models in
            if filterType == .month {
                self.generateMonthStatistic(fromDate: fromDate, toDate: toDate, for: models.allProgress)
            } else {
                let statModels = models.allProgress.map { WeelbeingStatisticModel(model: $0) }
                self.generateEmptyValues(fromDate: fromDate, toDate: toDate, models: statModels, filterType: filterType)
            }
            
            self.progressSection.send(models.weekProgress.statistic)
            self.walkSection.send(models.achievements.streaks.steps)
            self.completedTasksSection.send(models.achievements.streaks.dailyTasks)
            
            let badgeModels = [
                BadgeSliderModel(goal: models.achievements.budges.dailyTasks.goal, score: models.achievements.budges.dailyTasks.score, icon: models.achievements.budges.dailyTasks.icon),
                BadgeSliderModel(goal: 7_000, score: models.achievements.budges.steps.score, icon: nil, steps: Int(self.healthStore.stepCount.value))]
            self.sliderSection.send(badgeModels)
            
            if !models.weekProgress.wellbeingSurvey.isSkipped && models.weekProgress.wellbeingSurvey.isExist {
                let surveyModel = SurveyModel(survey: models.weekProgress.wellbeingSurvey, type: .wellbeing)
                
                if !self.surveysData.contains(surveyModel) {
                    self.surveysData.append(surveyModel)
                }
            } else {
                self.surveysData.removeAll(where: { $0.type == .wellbeing })
            }
            
            if !models.weekProgress.pulseSurvey.isSkipped && models.weekProgress.pulseSurvey.isExist {
                let surveyModel = SurveyModel(survey: models.weekProgress.pulseSurvey, type: .pulse)

                if !self.surveysData.contains(surveyModel) {
                    self.surveysData.append(surveyModel)
                }
            } else {
                self.surveysData.removeAll(where: { $0.type == .pulse })
            }
            self.surveySection.send(self.surveysData)
            self.breaksCount.send(models.achievements.availableBreaks)

            if surveysData.isEmpty {
                UserDefaults.allDataInDashBoardIsLoad = true
            }
            
        }.store(in: &cancellables)
    }
    
    private func generateMonthStatistic(fromDate: Date, toDate: Date, for models: [WeelbeingStatisticReponseModel]) {
    
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
    
        let weeks: [Int: [WeelbeingStatisticReponseModel]] = [0: [], 1: [], 2: [], 3: []]
        
        let data = models.reduce(weeks, { dict, el in
        
            let day = calendar.component(.day, from: Date(fromString: el.date, format: .custom("MM.dd.yyyy"))!.toZeroTime())
            
            let week = (day - 1) / 7
            
            if week > 3 {
                var dict = dict
                (dict[3, default: []]).append(el)
                return dict
            }
            
            var dict = dict
            (dict[week, default: []]).append(el)
            return dict
        })
        
        var sumGroupedModel = [Int: WeelbeingStatisticReponseModel]()
        
        for (key, values) in data {
            let model = WeelbeingStatisticReponseModel(date: values.first?.date ?? "",
                                                       eat: ProgressModel(total: values.map { $0.eat }.map { $0.total }.reduce(0, +),
                                                                          completed: values.map { $0.eat }.map { $0.completed }.reduce(0, +)),
                                                       move: ProgressModel(total: values.map { $0.move }.map { $0.total }.reduce(0, +),
                                                                           completed: values.map { $0.move }.map { $0.completed }.reduce(0, +)),
                                                       connect: ProgressModel(total: values.map { $0.connect }.map { $0.total }.reduce(0, +),
                                                                              completed: values.map { $0.connect }.map { $0.completed }.reduce(0, +)),
                                                       feel: ProgressModel(total: values.map { $0.feel }.map { $0.total }.reduce(0, +),
                                                                           completed: values.map { $0.feel }.map { $0.completed }.reduce(0, +)))
            sumGroupedModel[key] = model
        }
        
        let sorted = sumGroupedModel.sorted(by: { $0.key < $1.key })

        var clean = [WeelbeingStatisticReponseModel]()
    
        for value in sorted {
            switch value.key {
            case 0:
                clean.append(WeelbeingStatisticReponseModel(date: "1-7", eat: value.value.eat, move: value.value.move, connect: value.value.connect, feel: value.value.feel))
            case 1:
               clean.append(WeelbeingStatisticReponseModel(date: "8-14", eat: value.value.eat, move: value.value.move, connect: value.value.connect, feel: value.value.feel))
            case 2:
                clean.append(WeelbeingStatisticReponseModel(date: "15-21", eat: value.value.eat, move: value.value.move, connect: value.value.connect, feel: value.value.feel))
            default:
                let lastDay = self.getMonthDates(for: fromDate)
                clean.append(WeelbeingStatisticReponseModel(date: "22-" + String(lastDay), eat: value.value.eat, move: value.value.move, connect: value.value.connect, feel: value.value.feel))
            }
        }
        
        let converted = clean.map { WeelbeingStatisticModel(model: $0) }
        self.statisticSection.send(converted)

    }
    
    private func generateEmptyValues(fromDate: Date, toDate: Date, models: [WeelbeingStatisticModel], filterType: StatsDateType) {
        var date = fromDate
        var dates = [String]()
        let fmt = DateFormatter()
        fmt.dateFormat = filterType.stringFormatAPI
        
        while date <= toDate {
            dates.append(fmt.string(from: date))
            date = filterType.increaseDate(date)
        }
        
        var finalData = [WeelbeingStatisticModel]()
        
        dates.forEach({ date in
            let convertedDate: String = {
                if filterType == .month {
                    let startDate = Date(fromString: date, format: .custom(filterType.stringFormatAPI))!
                    let endDate = Date(fromString: date, format: .custom(filterType.stringFormatAPI))!.plus(days: 6)
                    return startDate.toString(format: .custom(filterType.stringFormatForChart)) + " - " + endDate.toString(format: .custom(filterType.stringFormatForChart))
                } else {
                  return Date(fromString: date, format: .custom(filterType.stringFormatAPI))!.toString(format: .custom(filterType.stringFormatForChart))
                }
            }()

                if models.contains(where: { $0.date == date }) {
                    let model = models.first(where: { $0.date == date })!
                    model.date = convertedDate
                    finalData.append(model)
                } else {
                    finalData.append(WeelbeingStatisticModel(date: convertedDate))
                }
        })
        
        self.statisticSection.send(finalData)
    }
    
    func getMoveStatistic() {
        self.healthStore.currentWeekSteps
            .receive(on: DispatchQueue.global(qos: .background))
            .sink(receiveValue: { [weak self] statistic in
                
                let fillStatistic = self?.fullfillStatistic(with: statistic) ?? []
                self?.moveProgressSection.send(fillStatistic)
            }).store(in: &cancellables)
    }
    
    private func fullfillStatistic(with statistic: [Stats]) -> [Stats] {
        let maxValue = statistic.map { Double($0.score) ?? 0 }.max() ?? 0
        let models = statistic.map { stat -> Stats in
            if (Double(stat.score) ?? 0) == 0 {
                return Stats(date: stat.date, score: "\(maxValue)", inactive: true)
            }
            return stat
        }
        return models
    }
    
    func takeBreak(type: BreaksType) {
        self.dashboardNetworkProvider.takeBreak(type: type)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [unowned self] model in
                self.breaksCount.send(model.availableBreaks)
                UserDefaults.numberOfClicks += 1
                UserDefaults.storedDate = Date()
            }).store(in: &cancellables)
    }
}
