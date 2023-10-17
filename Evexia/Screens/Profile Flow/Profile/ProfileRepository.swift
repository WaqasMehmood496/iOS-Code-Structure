//
//  ProfileRepository.swift
//  Evexia
//
//  Created by  Artem Klimov on 18.08.2021.
//

import Foundation
import Combine

protocol ProfileRepositoryProtocol {
    var dataSource: CurrentValueSubject<[ProfileCellContentType], Never> { get set }
    var tempSteps: Int { get }
    
    func getCarboneOffset()
    func setupBiometric(isOn: Bool, publisher: PassthroughSubject<Result<Bool, Error>, Never>)
    func logout() -> AnyPublisher<Result<Void, ServerError>, Never>
}

class ProfileRepository {
    
    var dataSource = CurrentValueSubject<[ProfileCellContentType], Never>([])
    var cancellables = Set<AnyCancellable>()
    var healthStore: HealthStore
    var tempSteps: Int = 0
    var impact = CurrentValueSubject<Double?, Never>(nil)
    var isStepsSend = false
    
    private let achievementsNetworkProvider: AchievmentsNetworkProviderProtocol
    private let userNetworkProvider: UserNetworkProviderProtocol
    private var isAciteStepRequest: Bool = false
    private let biometricService: BiometricdService
    
    init(healthStore: HealthStore,
         userNetworkProvider: UserNetworkProviderProtocol,
         achievementsNetworkProvider: AchievmentsNetworkProviderProtocol,
         biometricService: BiometricdService) {
        self.achievementsNetworkProvider = achievementsNetworkProvider
        
        self.healthStore = healthStore
        self.biometricService = biometricService
        self.userNetworkProvider = userNetworkProvider
        self.generateDataSource()
//      self.setCurrentDateSteps()
        self.observationFCMToken()
        self.setLastVisit()
        UserDefaults.userModel = UserDefaults.userModel
        
        self.healthStore.stepCount.removeDuplicates()
            .sink(receiveValue: { [weak self] steps in
                if steps >= 7_000 {
                    self?.checkIfAlertShownToday(steps: Int(steps))
                }
            }).store(in: &cancellables)
    }
    
    private func checkIfAlertShownToday(steps: Int) {
            if let lastAlertDate = UserDefaults.dateShowingWalkingStepsAchive {
                if Calendar.current.isDateInToday(lastAlertDate) {
                    print("Alert was shown today!")
                } else {
                    showStepAchievement(steps: steps)
                }
            } else {
                showStepAchievement(steps: steps)
            }
    }
    
    private func showStepAchievement(steps: Int) {
        let userInfo = ["steps": steps]
        UserDefaults.dateShowingWalkingStepsAchive = Date()
        NotificationCenter.default.post(name: Notification.Name("showStepAchievement"), object: nil, userInfo: userInfo)
    }
    
    deinit {
        Log.info("deinit -> \(self)")
    }
    
    private func setLastVisit() {
        if let lastVisit = UserDefaults.lastVisit, lastVisit.compare(.isYesterday) || lastVisit.compare(.isLastWeek) {
            userNetworkProvider.setLastVisit()
                .sink(receiveCompletion: { _ in }, receiveValue: { _ in
                    UserDefaults.lastVisit = Date()
                }).store(in: &cancellables)
        }
    }
    
    func refreshFCMTokenRequest(token: String) {
        
        userNetworkProvider.refreshFCMToken(token: token)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { _ in
            }).store(in: &cancellables)
    }
    
    func generateDataSource() {
        
        Publishers.CombineLatest4(getSettingsContent(), getUserProfile(), getDevices(), getStatistic())
            .map { settings, profile, devices, statistic in
                return [profile, statistic, .achievments, .personalDevelopment(.development), devices, settings]
            }.assign(to: \.value, on: self.dataSource)
            .store(in: &self.cancellables)
        UserDefaults.stepsCount = UserDefaults.stepsCount
        
    }
    
    func getSettingsContent() -> AnyPublisher<ProfileCellContentType, Never> {
        let settings = ProfileSettings.allCases
        return .just(.settings(content: settings))
    }
    
    func getUserProfile() -> AnyPublisher<ProfileCellContentType, Never> {
        return UserDefaults.$userModel
            .map { [weak self] user -> ProfileCellContentType in
                UserDefaults.isShowAchieve = user?.isShownAchievements ?? false
                if !(self?.isStepsSend ?? false) {
                    self?.isStepsSend = true
                    self?.checkSteps(user: user)
                }
                return .user(content: user)
            }.eraseToAnyPublisher()
    }
    
    func getCarboneOffset() {
        achievementsNetworkProvider.getCarbonOffset()
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] response in
                self?.impact.send(response.personalTotal)
            })
            .store(in: &cancellables)
    }
    
    func checkSteps(user: User?) {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
        dateFormatter.timeZone = .current
        if let user = user, let date = dateFormatter.date(from: user.stepsSyncDate) {
            if (Date().days(sinceDate: date) ?? 0 == 0 &&
                tempSteps >= 7_000) || Date().days(sinceDate: date) ?? 0 >= 1 {
                getStepStatistic(timeFrame: .period, date: date)
                return
            }
        }
        
        let dateFormatterOld = DateFormatter()
        let pattern = "yyyy-MM-dd"
        dateFormatter.timeZone = .current
        dateFormatterOld.dateFormat = pattern
        
        guard let user = user, let date = dateFormatterOld.date(from: user.stepsSyncDate)
        else { return }
        if (Date().days(sinceDate: date) ?? 0 == 0 &&
            tempSteps >= 7_000) || Date().days(sinceDate: date) ?? 0 >= 1 {
            getStepStatistic(timeFrame: .period, date: date)
        }
    }
    
    func setSteps(with stats: [Stats]) {
        let model = stats.map { LeaderboardSteps(stats: $0) }.filter { $0.value >= 7_000 }
        
        if !model.isEmpty {
            userNetworkProvider.setSteps(model: model)
                .sink(receiveCompletion: { _ in
                    self.isStepsSend = true
                    self.isAciteStepRequest = false },
                      receiveValue: { [weak self] _ in
                    guard let self = self else { return }
                    self.isAciteStepRequest = false
                }).store(in: &cancellables)
        }
    }
    
    func setCurrentDateSteps() {
         UserDefaults.$currentDayStepsCount
            .sink(receiveValue: { [weak self] currentSteps in
                guard let self = self else { return }
                if !self.isAciteStepRequest, let currentSteps = currentSteps, currentSteps >= 7_000 {
                    self.isAciteStepRequest = true
                    self.getStepStatistic(timeFrame: .period, date: Date().dateFor(.startOfDay))
                }
            }).store(in: &cancellables)
    }
    
    func getStepStatistic(timeFrame: StatsDateType, date: Date) {
        healthStore.getStepsStatistic(timeFrame: timeFrame, date: date)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] stats in
                self?.setSteps(with: stats)
            }).store(in: &cancellables)
    }
    
    func getDevices() -> AnyPublisher<ProfileCellContentType, Never> {
        return .just(.devices)
    }
    
    func getStatistic() -> AnyPublisher<ProfileCellContentType, Never> {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.unitsStyle = .positional
        dateFormatter.zeroFormattingBehavior = .pad
        dateFormatter.allowedUnits = [.hour, .minute]
        
        return Publishers.CombineLatest4(UserDefaults.$userModel.compactMap { $0 }, healthStore.stepCount.removeDuplicates(), healthStore.sleepHours.removeDuplicates(), Publishers.CombineLatest(UserDefaults.$stepsCount, impact.removeDuplicates()))
            .map { [unowned self] user, steps, sleep, stepsImpact in
                self.tempSteps = Int(steps)
                let time = dateFormatter.string(from: sleep)
                let formattedString = formatter.string(for: Int(steps))
                let weight: ProfileStatistic = .weight(value: user.weight)
                let sleep: ProfileStatistic = .sleep(value: time ?? "08:00")
                let score: ProfileStatistic = .score(value: user.wellbeingScore)
                let steps: ProfileStatistic = .steps(value: formattedString!)
                let text = String(stepsImpact.1 ?? 0.0).replacingOccurrences(of: ",", with: ".")
                let impact: ProfileStatistic = .impact(value: text)
                let calories = self.calculateCalories(for: user, activity: stepsImpact.0)
                let statisticModel = ProfileStatisticCellModel(userName: user.firstName, calories: calories, lastUpdate: UserDefaults.lastStatisticUpdate, statistic: [weight, sleep, score, steps, impact])
                return .statistic(content: statisticModel)
            }.eraseToAnyPublisher()
    }
    
    private func observationFCMToken() {
        UserDefaults.$firebaseCMToken.removeDuplicates()
            .sink(receiveValue: { [weak self]  token in
                guard let token = token else { return }
                self?.refreshFCMTokenRequest(token: token)
            }).store(in: &self.cancellables)
        
        UserDefaults.firebaseCMToken = UserDefaults.firebaseCMToken
    }
    
    private func calculateCalories(for user: User, activity: Int?) -> String? {
        var tempUser = user

        if !isMetricSystem {
            tempUser.weight = tempUser.weight.changeMeasurementSystem(unitType: .mass, manualMeasurement: (UnitMass.stones, UnitMass.pounds)).value
            tempUser.height = tempUser.height.changeMeasurementSystem(unitType: .lengh, manualMeasurement: (UnitLength.feet, UnitLength.inches)).value
        }
        guard let height = Double(tempUser.height), let weight = Double(tempUser.weight), let age = Double(tempUser.age), (tempUser.gender == .male || tempUser.gender == .female) else {
            return nil
        }
        var bmp = 0.0
        if tempUser.gender == .male {
            if isMetricSystem {
                bmp = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age)
            } else {
                bmp = 66.46 + (6.24 * weight) + (12.7 * height) - (6.755 * age)
            }
        }
        if tempUser.gender == .female {
            if isMetricSystem {
                bmp = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age)
            } else {
                bmp = 655.1 + (4.35 * weight) + (4.7 * height) - (4.7 * age)
            }
        }
        
        guard let steps = activity else { return nil }
        
        switch steps {
        case ...4_999:
            bmp *= 1.2
        case 5_000...7_499:
            bmp *= 1.375
        case 7_500...9_999:
            bmp *= 1.55
        case 10_000...12_499:
            bmp *= 1.725
        case 12_500...:
            bmp *= 1.9
        default:
            bmp *= 1.0
        }
        return String(Int(bmp))
    }
    
    func setupBiometric(isOn: Bool, publisher: PassthroughSubject<Result<Bool, Error>, Never>) {
        biometricService.auth(isOn: isOn, publisher: publisher)
    }
    
    func logout() -> AnyPublisher<Result<Void, ServerError>, Never> {
        return self.userNetworkProvider.logout()
            .map { [weak self] _ in
                self?.cleanUserData()
                return .success(())
            }
            .catch { [weak self] error -> AnyPublisher<Result<Void, ServerError>, Never> in
                self?.cleanUserData()
                return .just(.failure(error))
            }
            .eraseToAnyPublisher()
    }
    
    private func cleanUserData() {
        if let domain = Bundle.main.bundleIdentifier {
            let appHealsSync = UserDefaults.appleHealthSync
            let needShowDashBoardTutorial = UserDefaults.needShowDashBoardTutorial
            let isSignUpInProgress = UserDefaults.isSignUpInProgress
            let measurement = UserDefaults.measurement
            let isShowMeasurementPopUp = UserDefaults.isShowMeasurementPopUp
            let isFirstAccessToBiometric = UserDefaults.isFirstAccessToBiometric
            let isFirstAccessiNSettingsToBiometric = UserDefaults.isFirstAccessiNSettingsToBiometric

            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.appleHealthSync = appHealsSync
            UserDefaults.needShowDashBoardTutorial = needShowDashBoardTutorial
            UserDefaults.isSignUpInProgress = isSignUpInProgress
            UserDefaults.isShowMeasurementPopUp = isShowMeasurementPopUp
            UserDefaults.measurement = measurement
            UserDefaults.isFirstAccessToBiometric = isFirstAccessToBiometric
            UserDefaults.isFirstAccessiNSettingsToBiometric = isFirstAccessiNSettingsToBiometric
        }
    }
}

extension ProfileRepository: ProfileRepositoryProtocol {}
