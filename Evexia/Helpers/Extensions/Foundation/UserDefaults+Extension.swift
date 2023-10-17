//
//  UserDefaults+PropertyWrapper.swift
//  Evexia
//
//  Created by  Artem Klimov on 08.07.2021.
//

import Foundation
import Combine
  
// UserDefaults Keys
extension UserDefaults {
    
    @objc dynamic var stepsCount: Int {
        return integer(forKey: "stepsCount")
    }
    
    // - accessToken
    @Wrapper(key: "accessToken")
    
    static var accessToken: String?
    
    // - refreshToken
    @Wrapper(key: "refreshToken")
    
    static var refreshToken: String?
    
    // - FCM token
    @Wrapper(key: "firebaseCMToken")
    
    static var firebaseCMToken: String?
    
    // - FCM token storage
    @Storage(key: "firebaseCMTokenStorage", defaultValue: nil)
    
    static var firebaseCMTokenStorage: String?
    
    // - verificationToken
    @Wrapper(key: "verificationToken")
    
    static var verificationToken: String?
    
    // - email
    @Wrapper(key: "email")
    
    static var email: String?
    
    // - isSignUpInProgress
    @Wrapper(key: "isSignUpInProgress")
    static var isSignUpInProgress: Bool?
    
    // - userModel
    @Wrapper(key: "userModel")
    
    static var userModel: User?
    
    // - isOnboardingDone
    @Storage(key: "isOnboardingDone", defaultValue: true)
    
    static var isOnboardingDone: Bool
    
    // - user steps count
    @Wrapper(key: "stepsCount")
    
    static var stepsCount: Int?
    
    // - user current day steps count
    @Wrapper(key: "currentDayStepsCount")
    
    static var currentDayStepsCount: Int?
    
    // - isShowDailyGoalView
    @Wrapper(key: "isShowDailyGoalView")
    
    static var isShowDailyGoalView: Bool?
    
    // - oneDay
    @Wrapper(key: "oneDay")
    
    static var oneDay: Date?
    
    // - last update
    @Wrapper(key: "lastStatisticUpdate")
    
    static var lastStatisticUpdate: Double?
    
    // - app health sync
    @Wrapper(key: "appleHealthSync")
    
    static var appleHealthSync: Bool?
    
    // - isSocialLoginUser
    @Storage(key: "isSocialLoginUser", defaultValue: false)
    
    static var isSocialLoginUser: Bool
    
    // - hideMyGoalsHint
    @Storage(key: "hideMyGoalsHint", defaultValue: false)
    
    static var hideMyGoalsHint: Bool
    
    // - hideMyWhysHint
    @Storage(key: "hideMyWhysHint", defaultValue: false)
    
    static var hideMyWhysHint: Bool
    
    // - hideAdwiseAndSupport
    @Storage(key: "hideAdwiseAndSupport", defaultValue: false)
    
    static var hideAdwiseAndSupport: Bool
    
    // - needShowLibraryTutorial
    @Storage(key: "needShowLibraryTutorial", defaultValue: false)

    static var needShowLibraryTutorial: Bool
    
    // - needShowDiaryTutorial
    @Storage(key: "needShowDiaryTutorial", defaultValue: false)

    static var needShowDiaryTutorial: Bool
    
    // - needShowDashBoardTutorial
    @Storage(key: "needShowDashBoardTutorial", defaultValue: false)

    static var needShowDashBoardTutorial: Bool
    
    // - needShowDashBoardTutorial
    @Storage(key: "allDataInDashBoardIsLoad", defaultValue: false)

    static var allDataInDashBoardIsLoad: Bool
    
    // - lastVisit
    @Storage(key: "lastVisit", defaultValue: nil)
    
    static var lastVisit: Date?

    // - isSocialLoginUser
    @Wrapper(key: "focusCard")
    
    static var focusCard: [Int: Focus?]?
    
    // - currentTutorial
    @Wrapper(key: "currentTutorial")
    
    static var currentTutorial: Tutorials?
    
    // - isShowAchieve
    @Storage(key: "isShowAchieve", defaultValue: false)
    
    static var isShowAchieve: Bool
    
    // - storedDate
    @Storage(key: "storedDate", defaultValue: nil)
    
    static var storedDate: Date?
    
    // - numClicks
    @Storage(key: "numberOfClicks", defaultValue: 1)
    
    static var numberOfClicks: Int
    
    // - isShowSavePlanetPopUp
    @Storage(key: "isShowSavePlanetPopUp", defaultValue: false)
    
    static var isShowSavePlanetPopUp: Bool
    
    // - dateShowingWalkingStepsAchive
    @Storage(key: "dateShowingWalkingStepsAchive", defaultValue: nil)
    
    static var dateShowingWalkingStepsAchive: Date?
    
    // - dailyTaskIsShowPopUp
    @Storage(key: "dailyTaskIsShowPopUp", defaultValue: DailyTaskShowPopUp())
    
    static var dailyTaskIsShowPopUp: DailyTaskShowPopUp
    
    // - countDailyTasks
    @Wrapper(key: "countDailyTasks")
    
    static var countDailyTasks: Int?
    
    // - biometricСonfirmationTime
    @Storage(key: "biometricСonfirmationTime", defaultValue: nil)
    
    static var biometricСonfirmationTime: Date?
    
    // - biometricСonfirmationisOn
    @Wrapper(key: "biometricСonfirmationisOn")
    
    static var biometricСonfirmationisOn: Bool?
    
    // - measurement
    @Storage(key: "measurement", defaultValue: "U.K.")
    
    static var measurement: String
    
    // - isShowMeasurementPopUp
    @Storage(key: "isShowMeasurementPopUp", defaultValue: false)
    
    static var isShowMeasurementPopUp: Bool

    // - isFirstAccessToBiometric
    @Storage(key: "isFirstAccessToBiometric", defaultValue: true)

    static var isFirstAccessToBiometric: Bool

    // - isFirstAccessiNSettingsToBiometric
    @Storage(key: "isFirstAccessiNSettingsToBiometric", defaultValue: true)

    static var isFirstAccessiNSettingsToBiometric: Bool
}

// MARK: - Optional Wrapper
@propertyWrapper
struct Wrapper<T: Codable> {
     let key: String
     var storage: UserDefaults = .standard
     private let publisher = PassthroughSubject<T?, Never>()

    var projectedValue: AnyPublisher<T?, Never> {
        return publisher.eraseToAnyPublisher()
    }

     var wrappedValue: T? {
         get {
           guard let data = UserDefaults.standard.object(forKey: key) as? Data else {
                return nil
            }
            let value = try? JSONDecoder().decode(T.self, from: data)
            return value
         }
         set {
            if newValue.isNil {
                self.storage.removeObject(forKey: key)
            } else {
                let data = try? JSONEncoder().encode(newValue)
                    UserDefaults.standard.set(data, forKey: key)
                }
            self.publisher.send(newValue)
         }
     }
 }

private protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
}

// MARK: - Storage
@propertyWrapper
struct Storage<T> {
    private let key: String
    private let defaultValue: T

    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
