//
//  WellbeingRepository.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 29.08.2021.
//

import Foundation
import Combine
import UIKit

protocol WellbeingRepositoryProtocol {
    
    func getStatistic(timeFrame: StatsDateType, startDate: Date, endDate: Date) -> AnyPublisher<[Stats], ServerError>
    
    func getHealthStatistic(date: Date, timeFrame: StatsDateType) -> AnyPublisher<[Stats], ServerError>
    func getSleepStatistic(startDate: Date, endDate: Date, timeFrame: StatsDateType) -> AnyPublisher<[Stats], Never>
    
    var dataSource: PassthroughSubject<[Stats], ServerError> { get }
    var entriesdDataSource: PassthroughSubject<[Stats], ServerError> { get }
}

final class WellbeingRepository {
    
    var dataSource = PassthroughSubject<[Stats], ServerError>()
    var entriesdDataSource = PassthroughSubject<[Stats], ServerError>()
    
    private let networkProvider: StatisticNetworkProviderProtocol
    private let healthStore: HealthStore
    private let statisticType: StatisticType
    private var cancellables = Set<AnyCancellable>()
    
    init(networkProvider: StatisticNetworkProviderProtocol, healthStore: HealthStore, statisticType: StatisticType) {
        self.networkProvider = networkProvider
        self.healthStore = healthStore
        self.statisticType = statisticType
    }
    
    private func getMonthDates(for date: Date) -> String {
        
        var calendar = Calendar.current
        calendar.locale = .current
        
        let interval = calendar.dateInterval(of: .month, for: date)!
        
        let days = calendar.dateComponents([.day], from: interval.start, to: interval.end).day!
        return String(days)
    }
    
}

extension WellbeingRepository: WellbeingRepositoryProtocol {
    
    func getHealthStatistic(date: Date, timeFrame: StatsDateType) -> AnyPublisher<[Stats], ServerError> {
        
        guard UserDefaults.appleHealthSync ?? false else {
            return .just([])
        }
        
        return healthStore.getStepsStatistic(timeFrame: timeFrame, date: date)
            .mapError({ _ in ServerError(errorCode: .blockedUser) })
            .map { [unowned self] response -> [Stats] in
                
                var wellbeing = response.compactMap { stats -> Stats in
                    return Stats(date: self.format(stats.date, for: timeFrame), score: stats.score, inactive: stats.inactive)
                }
                
                if timeFrame == .month {
                    let lastDay = self.getMonthDates(for: date)
                    
                    if wellbeing.count > 4 {
                        let lastWeekStat = Stats(date: "22 - " + lastDay, score: "\(Double(wellbeing[3].score) ?? 0 + Double(wellbeing[4].score)!)", inactive: false)
                        wellbeing.removeLast(2)
                        wellbeing.append(lastWeekStat)
                    }
                }
                
                return wellbeing
            }
            .eraseToAnyPublisher()
    }
    
    func getSleepStatistic(startDate: Date, endDate: Date, timeFrame: StatsDateType) -> AnyPublisher<[Stats], Never> {
        
        guard UserDefaults.appleHealthSync ?? false else {
            return .just([])
        }
        
        return  self.healthStore.getSleepStatistic(startDate: startDate, endDate: endDate, filterType: timeFrame)
            .map { [unowned self] response -> [Stats] in
                if timeFrame == .month {
                    let lastDay = self.getMonthDates(for: startDate)
                    let response = response.map { StatsResponseModel(date: $0.date, value: $0.score, timestamp: Date(fromString: $0.date, format: .custom("MM.dd.yyyy"))?.timeIntervalSince1970) }
                    var wellbeing = self.fullfillMonthStatistic(timeFrame: timeFrame, startDate: startDate, endDate: endDate, statistic: response)
                    if wellbeing.count > 4 {
                        let lastWeekStat = Stats(date: "22 - " + lastDay, score: "\((Double(wellbeing[3].score) ?? 0 + Double(wellbeing[4].score)!) / 2) ", inactive: false)
                        wellbeing.removeLast(2)
                        wellbeing.append(lastWeekStat)
                    }
                    return wellbeing
                } else {
                    let wellbeing = response.compactMap { stats -> Stats in
                        return Stats(date: self.format(stats.date, for: timeFrame), score: stats.score, inactive: stats.inactive)
                    }
                    return wellbeing
                    
                }
                
            }
            .eraseToAnyPublisher()
    }
    
    func getStatistic(timeFrame: StatsDateType, startDate: Date, endDate: Date) -> AnyPublisher<[Stats], ServerError> {
        
        switch self.statisticType {
        case .steps, .sleep:
            return .just([])
        case .weight:
            return self.getWeightStatistic(timeFrame: timeFrame, startDate: startDate, endDate: endDate)
        case .wellbeing:
            return self.getWellbeingStatistic(timeFrame: timeFrame, startDate: startDate, endDate: endDate)
            
        }
    }
    
    func getWeightStatistic(timeFrame: StatsDateType, startDate: Date, endDate: Date) -> AnyPublisher<[Stats], ServerError> {
        let requestModel = StatsRequestModel(type: timeFrame.value, dateFrom: startDate.timeMillis, dateTo: endDate.timeMillis)
        return self.networkProvider.getWeightStatistic(for: requestModel)
            .map { [unowned self] response -> [Stats] in
                
                let dataSource = response.entries.compactMap { Stats(date: self.formatEtries($0.timestamp), score: isMetricSystem ? $0.value : $0.value.changeMeasurementSystem(unitType: .mass).value, inactive: false) }
                
                self.entriesdDataSource.send(dataSource)
                
                if timeFrame == .month {
                    return self.fullfillMonthStatistic(timeFrame: timeFrame, startDate: startDate, endDate: endDate, statistic: response.statistic, isWeight: true)
                } else {
                    return self.generateEmptyValues(fromDate: startDate, toDate: endDate, models: response.statistic, filterType: timeFrame, isWeight: true)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func getWellbeingStatistic(timeFrame: StatsDateType, startDate: Date, endDate: Date) -> AnyPublisher<[Stats], ServerError> {
        let requestModel = StatsRequestModel(type: timeFrame.value, dateFrom: startDate.timeMillis, dateTo: endDate.timeMillis)
        return self.networkProvider.getWellbeingStatistic(for: requestModel)
            .map { [unowned self] response -> [Stats] in
                if timeFrame == .month {
                    return self.fullfillMonthStatistic(timeFrame: timeFrame, startDate: startDate, endDate: endDate, statistic: response)
                } else {
                    return self.generateEmptyValues(fromDate: startDate, toDate: endDate, models: response, filterType: timeFrame)
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func fullfillMonthStatistic(timeFrame: StatsDateType, startDate: Date, endDate: Date, statistic: [StatsResponseModel], isWeight: Bool = false) -> [Stats] {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        
        let weeks: [Int: [StatsResponseModel]] = [0: [], 1: [], 2: [], 3: []]
        
        let data = statistic.reduce(weeks, { dict, el in
            let date = Date(fromString: el.date, format: .custom("MM.dd.yyyy"))!.toZeroTime()
            let day = calendar.component(.day, from: date)
            
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
        
        var filtered = [Int: StatsResponseModel?]()
        
        for (key, _) in data {
            let max = data[key]?.max(by: { (Double($0.value) ?? 0) < (Double($1.value) ?? 0) })
            
            filtered[key] = max
        }
        
        let sorted = filtered.sorted(by: { $0.key < $1.key })
        
        var clean = [Stats]()


        
        for value in sorted {
            let defaultValue = value.value?.value ?? "0"
            let score = isWeight ? (isMetricSystem ? defaultValue : defaultValue.changeMeasurementSystem(unitType: .mass).value) : defaultValue

            switch value.key {
            case 0:
                clean.append(Stats(date: "1-7", score: score, inactive: false))
            case 1:
                clean.append(Stats(date: "8-14", score: score, inactive: false))
            case 2:
                clean.append(Stats(date: "15-21", score: score, inactive: false))
            default:
                let lastDay = self.getMonthDates(for: startDate)
                clean.append(Stats(date: "22-" + String(lastDay), score: score, inactive: false))
            }
        }
        return clean
    }
    
    private func generateEmptyValues(fromDate: Date, toDate: Date, models: [StatsResponseModel], filterType: StatsDateType, isWeight: Bool = false) -> [Stats] {
        var date = fromDate
        var dates = [String]()
        let fmt = DateFormatter()
        fmt.dateFormat = filterType.stringFormatAPI
        
        while date <= toDate {
            dates.append(fmt.string(from: date))
            date = filterType.increaseDate(date)
        }
        
        var finalData = [Stats]()
        
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
                var model = models.first(where: { $0.date == date })!
                model.date = convertedDate
                let value = isWeight ? (isMetricSystem ? model.value : model.value.changeMeasurementSystem(unitType: .mass).value) : model.value
                
                finalData.append(Stats(date: convertedDate, score: value, inactive: false))
            } else {
                finalData.append(Stats(date: convertedDate, score: "0", inactive: true))
            }
        })
        
        return finalData
    }
    
    private func formatEtries(_ date: Double?) -> String {
        let formatter = DateFormatter()
        var pattern = "MM.dd.yyyy"
        formatter.dateFormat = pattern
        
        guard let timastamp = date else {
            return ""
        }
        
        let newDate = Date(timeIntervalSince1970: timastamp / 1_000)
        
        pattern = "EEEE dd MMMM yyyy"
        formatter.dateFormat = pattern
        return formatter.string(from: newDate)
    }
    
    private func format(_ date: String, for type: StatsDateType) -> String {
        let formatter = DateFormatter()
        var pattern: String!
        
        switch statisticType {
        case .steps:
            pattern = "dd MMMM yyyy"
        case .sleep:
            pattern = "MM.dd.yyyy"
        default:
            switch type {
            case .year:
                pattern = "MM.yyyy"
            case .month:
                pattern = "ww.Y"
            case .week:
                pattern = "MM.dd.yyyy"
            default: break
            }
        }
        
        formatter.dateFormat = pattern
        
        let newDate = formatter.date(from: date) ?? Date()
        
        switch type {
        case .week:
            pattern = "EEE"
            formatter.dateFormat = pattern
            return formatter.string(from: newDate)
            
        case .month:
            let patternNew = "dd"
            formatter.dateFormat = patternNew
            let startDate = formatter.string(from: newDate)
            var endDate = formatter.string(from: newDate)
            
            if statisticType == .steps || statisticType == .sleep {
                endDate = formatter.string(from: newDate.plus(days: 6))
            }
            return startDate + " - " + endDate
        case .year:
            pattern = "MMM"
            formatter.dateFormat = pattern
            let string = formatter.string(from: newDate)
            return string
        default:
            return ""
        }
    }
}
