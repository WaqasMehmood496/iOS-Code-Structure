//
//  WellbeingVM.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 26.08.2021.
//

import Foundation
import Combine

final class WellbeingVM {
    
    private let repository: WellbeingRepositoryProtocol
    
    private var cancellables: [AnyCancellable] = []
    private var requestCancellable = Set<AnyCancellable>()
    var curentFilterType = CurrentValueSubject<StatsDateType, Never>(.week)
    var intervalValue = CurrentValueSubject<String, Never>("")
    private var router: WellbeingNavigation
    private var currentFilterDate: Date = Date().toZeroTime()
    private var startFilterDate: Date = Date()
    private var endFilterDate: Date = Date()
    var dataSource = PassthroughSubject<[Stats], ServerError>()
    var entriesDataSource = PassthroughSubject<[Stats], ServerError>()
    var user = CurrentValueSubject<User?, Never>(nil)

    var statisticType: StatisticType
    
    init(router: WellbeingNavigation, repository: WellbeingRepositoryProtocol, statisticType: StatisticType) {
        self.repository = repository
        self.statisticType = statisticType
        self.router = router
        
        self.binding()
    }
    
    private func binding() {
        self.curentFilterType
            .sink(receiveValue: { [weak self] value in
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
                self?.updateDistance()

                self?.getStatistic()
            }).store(in: &cancellables)
        
        if statisticType == .weight {
            self.weightBinding()
        }
    }
    
    private func weightBinding() {
        self.repository.entriesdDataSource
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] entries in
                    self?.entriesDataSource.send(entries)
                  })
            .store(in: &cancellables)
        
        UserDefaults.$userModel
            .sink(receiveValue: { [weak self] userModel in
                self?.user.send(userModel)
                self?.getStatistic()
            }).store(in: &cancellables)
        
        self.user.send(UserDefaults.userModel)
    }
    
    private func getStatistic() {
        self.requestCancellable.forEach { $0.cancel() }
        self.requestCancellable.removeAll()
        if self.statisticType == .steps {
            self.repository.getHealthStatistic(date: currentFilterDate, timeFrame: self.curentFilterType.value)
                .replaceError(with: [])
                .sink(receiveValue: { [weak self] statistic in
                    self?.fullfillStatistic(with: statistic)
                }).store(in: &requestCancellable)
        } else  if self.statisticType == .sleep {
            self.repository.getSleepStatistic(startDate: self.startFilterDate, endDate: self.endFilterDate, timeFrame: self.curentFilterType.value)
                .replaceError(with: [])
                .sink(receiveValue: { [weak self] statistic in
                    self?.fullfillStatistic(with: statistic)
                }).store(in: &requestCancellable)
        } else {
            self.repository.getStatistic(timeFrame: self.curentFilterType.value, startDate: startFilterDate, endDate: endFilterDate)
                .replaceError(with: [])
                .sink(receiveValue: { [weak self] statistic in
                    self?.fullfillStatistic(with: statistic)
                }).store(in: &requestCancellable)
        }
        
    }
    
    private func fullfillStatistic(with statistic: [Stats]) {
        let maxValue = statistic.map { Double($0.score) ?? 0 }.max() ?? 0
        let models = statistic.map { stat -> Stats in
            if (Double(stat.score) ?? 0) == 0 {
                return Stats(date: stat.date, score: "\(maxValue)", inactive: true)
            }
            return stat
        }
        
        self.dataSource.send(models)
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
        
        self.getStatistic()
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
        
        self.getStatistic()
        self.updateDistance()
    }
    
    private func getWeekStartFromCurrentDate() {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        calendar.firstWeekday = 2
        let components = calendar.dateComponents([.year, .weekOfYear, .yearForWeekOfYear], from: self.currentFilterDate)
            
        self.startFilterDate = calendar.startOfDay(for: calendar.date(from: components)!)
        self.endFilterDate = self.startFilterDate.plus(seconds: 604_799)
    }
    
    private func getMonthStartFromCurrentDate() {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        calendar.firstWeekday = 2
        
        let components = calendar.dateComponents([.year ,.month], from: self.currentFilterDate)
        self.startFilterDate = calendar.startOfDay(for: calendar.date(from: components)!)
        self.endFilterDate = self.startFilterDate.plus(months: 1).minus(seconds: 1)
    }
    
    private func getYearStartFromCurrentDate() {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        calendar.firstWeekday = 2
        
        let components = calendar.dateComponents([.year], from: self.currentFilterDate)
        self.startFilterDate = calendar.startOfDay(for: calendar.date(from: components)!)
        self.endFilterDate = self.startFilterDate.plus(years: 1).minus(seconds: 1)
    }
    
    private func updateDistance() {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")!

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
    
    func navigateToSetWeight() {
        let model = ProfileCellModel(value: self.user.value?.weight ?? "", type: .weight)
        self.router.navigateToSeWeight(model: model)
    }
}

extension Date: Strideable {
    public func distance(to other: Date) -> TimeInterval {
        return other.timeIntervalSinceReferenceDate - self.timeIntervalSinceReferenceDate
    }

    public func advanced(by n: TimeInterval) -> Date {
        return self + n
    }
}
