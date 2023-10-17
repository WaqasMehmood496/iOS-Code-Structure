//
//  HealthStore.swift
//  Evexia
//
//  Created by  Artem Klimov on 27.08.2021.
//

import Foundation
import HealthKit
import Combine

protocol HealthStoreUseCase {
    var stepCount: CurrentValueSubject<Double, Never> { get }
    var sleepHours: CurrentValueSubject<Double, Never> { get }
    var currentWeekSteps: PassthroughSubject<[Stats], Never> { get }
}

class HealthStore {
    
    var sleepHours = CurrentValueSubject<Double, Never>(0.0)
    var stepCount = CurrentValueSubject<Double, Never>(0.0)
    var currentWeekSteps = PassthroughSubject<[Stats], Never>()
    
    var healthStore: HKHealthStore
    let sampleType = HKObjectType.quantityType(forIdentifier: .stepCount)!
    var cancellables = Set<AnyCancellable>()
    var observingQuery: HKObserverQuery?
    
    init() {
        self.healthStore = HKHealthStore()
        self.binding()
    }
    
    private func binding() {
        UserDefaults.$appleHealthSync
            .sink(receiveValue: { [weak self] value in
                if !(value ?? true) {
                    self?.stepCount.send(0)
                    guard (self?.observingQuery) != nil else { return }
                    self?.healthStore.stop((self?.observingQuery!)!)
                } else {
                    self?.startObserving()
                    self?.getTodaySleepHours()
                }
            }).store(in: &cancellables)
        
        UserDefaults.appleHealthSync = UserDefaults.appleHealthSync ?? false
        
    }
    
    func getTodaySleepHours() {
        
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            var sleepTime = TimeInterval()
            
            let startDay = Date().minus(days: 1)
            let endDate = Date()
            let predicate = HKQuery.predicateForSamples(withStart: startDay, end: endDate, options: .strictStartDate)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 100_000, sortDescriptors: [sortDescriptor]) { [weak self] _, tmpResult, error -> Void in
                if error != nil {
                    return
                }
                if let result = tmpResult {
                    for item in result {
                        if let sample = item as? HKCategorySample {
                            
                            let sleepTimeForOneDay = sample.endDate.timeIntervalSince(sample.startDate)
                            if sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue {
                                sleepTime += sleepTimeForOneDay
                            }
                        }
                    }
                    self?.sleepHours.send(sleepTime)
                }
            }
            healthStore.execute(query)
        }
    }
    
    func getSleepStatistic(startDate: Date, endDate: Date, filterType: StatsDateType) -> AnyPublisher<[Stats], Never> {
        var date = startDate.toZeroTime()
        
        var publishers = [AnyPublisher<Stats, Error>]()
        
        while date <= endDate {
            publishers.append(self.getSleepStatisticFor(startDate: date, endDate: filterType.increaseDate(date), filerType: filterType))
            date = filterType.increaseDate(date)
        }
        
        return Publishers.ZipMany(publishers)
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func getSleepStatisticFor(startDate: Date, endDate: Date, filerType: StatsDateType) -> AnyPublisher<Stats, Error> {
        let subject = PassthroughSubject<Stats, Error>()
        
        var calendar = Calendar.current
        calendar.locale = .current
        let interval = endDate.timeIntervalSince(startDate)
        
        let days = interval / 3_600 / 24
        
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            var sleepTime = TimeInterval()
            let ft = filerType
            
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 100_000, sortDescriptors: [sortDescriptor]) { _, tmpResult, error -> Void in
                if error != nil {
                    return
                }
                
                let dispatchGroup = DispatchGroup()
                
                if let result = tmpResult {
                    dispatchGroup.enter()
                    
                    for item in result {
                        if let sample = item as? HKCategorySample {
                            let sleepTimeForOneDay = sample.endDate.timeIntervalSince(sample.startDate)
                            if sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue {
                                sleepTime += sleepTimeForOneDay
                            }
                        }
                        
                    }
                    dispatchGroup.leave()
                }
                let dateFormatter = DateFormatter()
                dateFormatter.locale = .current
                let pattern = "MM.dd.yyyy"
                dateFormatter.dateFormat = pattern
                let dateString = dateFormatter.string(from: startDate)
                dispatchGroup.notify(queue: .main) {
                    
                    if sleepTime == 0 {
                        subject.send(Stats(date: dateString, score: String(sleepTime), inactive: true))
                    } else {
                        if ft == .year {
                            subject.send(Stats(date: dateString, score: String(sleepTime), inactive: false))
                        } else {
                            subject.send(Stats(date: dateString, score: String(sleepTime / days), inactive: false))
                        }
                    }
                    subject.send(completion: .finished)
                }
            }
            healthStore.execute(query)
        }
        return subject.eraseToAnyPublisher()
    }
    
    func startObserving() {
        
        observingQuery = HKObserverQuery(sampleType: sampleType, predicate: nil) { [weak self] _, _, _ in
            guard let self = self else { return }
            self.getTodaysSteps()
            
            self.getWeekStatistic(for: Date())
                .sink(receiveCompletion: { _ in },
                      receiveValue: { statistic in
                    let weekday = self.calculateWeekDay()
                    let avarage = statistic.compactMap { Double($0.score) }.reduce(0, +) / Double(weekday)
                    let avarageInt: Int = avarage.isNaN ? 0 : Int(avarage)
                    UserDefaults.stepsCount = avarageInt
                    self.currentWeekSteps.send(statistic)
                }).store(in: &self.cancellables)
        }
        
        self.healthStore.execute(observingQuery!)
    }
    
    private func calculateWeekDay() -> Int {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        return weekday == 1 ? 7 : weekday - 1
    }
    
    func getTodaysSteps() {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                return
            }
            let currentDaySteps = sum.doubleValue(for: HKUnit.count())
            UserDefaults.currentDayStepsCount = Int(currentDaySteps)
            self?.stepCount.send(currentDaySteps)
        }
        self.healthStore.execute(query)
    }
    
    private func getStatisticFor(startDate: Date, endDate: Date, anchorDate: Date, slice: DateComponents, background: Bool = false) -> PassthroughSubject<[Stats], Error> {
        let subject = PassthroughSubject<[Stats], Error>()
        
        let query = HKStatisticsCollectionQuery(quantityType: sampleType, quantitySamplePredicate: nil, options: [.cumulativeSum], anchorDate: anchorDate, intervalComponents: slice)
        
        query.initialResultsHandler = { _, results, _ in
            guard let results = results else {
                return
            }
            
            var statistic = [Stats]()
            
            let dispatchGroup = DispatchGroup()
            let dateFormatter = DateFormatter()
            let pattern = "dd MMMM yyyy"
            dateFormatter.dateFormat = pattern
            
            results.enumerateStatistics(from: anchorDate, to: endDate) { statistics, _ in
                dispatchGroup.enter()
                if let sum = statistics.sumQuantity() {
                    let steps = sum.doubleValue(for: HKUnit.count())
                    let startDate = dateFormatter.string(from: statistics.startDate)
                    statistic.append(Stats(date: startDate, score: String(steps), inactive: false))
                    dispatchGroup.leave()
                } else {
                    let startDate = dateFormatter.string(from: statistics.startDate)
                    statistic.append(Stats(date: startDate, score: "0", inactive: true))
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main) {
                subject.send(statistic)
                subject.send(completion: .finished)
            }
        }
        
        self.healthStore.execute(query)
        
        if background {
            healthStore.enableBackgroundDelivery(for: sampleType, frequency: .immediate, withCompletion: { _, _ in })
        }
        return subject
    }
    
    func getStepsStatistic(timeFrame: StatsDateType, date: Date) -> AnyPublisher<[Stats], Error> {
        switch timeFrame {
        case .week:
            return self.getWeekStatistic(for: date)
        case .month:
            return self.getMonthStatistic(for: date)
        case .year:
            return self.getYearStatistic(for: date)
        case .period:
            return self.getPeriodStatistic(for: date)
        }
    }
    
    func getYesterdaySteps() -> AnyPublisher<[Stats], Error> {
        let start = Date().minus(days: 1).startOfDay
        let end = start.plus(days: 1).minus(seconds: 1)
        var slice = DateComponents()
        slice.day = 1
        
        return self.getStatisticFor(startDate: start, endDate: end, anchorDate: start, slice: slice, background: false).eraseToAnyPublisher()
    }
    
    private func getPeriodStatistic(for date: Date) -> AnyPublisher<[Stats], Error> {
        var slice = DateComponents()
        slice.day = 1
        
        return self.getStatisticFor(startDate: date, endDate: Date(), anchorDate: date, slice: slice)
            .eraseToAnyPublisher()
    }
    
    private func getYearStatistic(for date: Date) -> AnyPublisher<[Stats], Error> {
        var calendar = Calendar.current
        calendar.timeZone = .current
        
        let components = calendar.dateComponents([.year], from: date)
        let anchorDate = calendar.startOfDay(for: calendar.date(from: components)!)
        let endDate = anchorDate.plus(years: 1).minus(seconds: 1)
        
        var slice = DateComponents()
        slice.month = 1
        
        return self.getStatisticFor(startDate: anchorDate, endDate: endDate, anchorDate: anchorDate, slice: slice)
            .eraseToAnyPublisher()
    }
    
    private func getMonthStatistic(for date: Date) -> AnyPublisher<[Stats], Error> {
        var calendar = Calendar.current
        calendar.timeZone = .current
        let components = calendar.dateComponents([.year, .month], from: date)
        let anchorDate = calendar.startOfDay(for: calendar.date(from: components)!)
        let endDate = anchorDate.plus(months: 1).minus(seconds: 1)
        
        var slice = DateComponents()
        slice.weekOfMonth = 1
        
        return self.getStatisticFor(startDate: anchorDate, endDate: endDate, anchorDate: anchorDate, slice: slice)
            .eraseToAnyPublisher()
    }
    
    private func getWeekStatistic(for date: Date) -> AnyPublisher<[Stats], Error> {
        var calendar = Calendar.current
        calendar.timeZone = .current
        let components = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: date)
        let anchorDate = calendar.startOfDay(for: calendar.date(from: components)!)
        let endDate = anchorDate.plus(days: 7).minus(seconds: 1)
        
        var slice = DateComponents()
        slice.day = 1
        
        return self.getStatisticFor(startDate: anchorDate, endDate: endDate, anchorDate: anchorDate, slice: slice)
            .eraseToAnyPublisher()
    }
    
    deinit {
        Log.info("deinit -> \(self)")
    }
}

extension Publishers {
    struct ZipMany<Element, F: Error>: Publisher {
        typealias Output = [Element]
        typealias Failure = F
        
        private let upstreams: [AnyPublisher<Element, F>]
        
        init(_ upstreams: [AnyPublisher<Element, F>]) {
            self.upstreams = upstreams
        }
        
        func receive<S: Subscriber>(subscriber: S) where Self.Failure == S.Failure, Self.Output == S.Input {
            let initial = Just<[Element]>([])
                .setFailureType(to: F.self)
                .eraseToAnyPublisher()
            
            let zipped = upstreams.reduce(into: initial) { result, upstream in
                result = result.zip(upstream) { elements, element in
                    elements + [element]
                }
                .eraseToAnyPublisher()
            }
            
            zipped.subscribe(subscriber)
        }
    }
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: startOfDay)
        return Calendar.current.date(from: components)!
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth)!
    }
}
