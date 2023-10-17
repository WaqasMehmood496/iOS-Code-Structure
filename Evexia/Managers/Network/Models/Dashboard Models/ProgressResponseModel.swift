//
//  ProgressResponseModel.swift
//  Evexia
//
//  Created by admin on 11.09.2021.
//

import Foundation

// MARK: - ProgressResponseModel
struct ProgressResponseModel: Decodable, Hashable {
    var statistic: WeekStatistic
    var pulseSurvey: SurveyResponseModel
    var wellbeingSurvey: SurveyResponseModel
    
    static func == (lhs: ProgressResponseModel, rhs: ProgressResponseModel) -> Bool {
        lhs.statistic == rhs.statistic
    }
}

// MARK: - WeekStatistic
struct WeekStatistic: Decodable, Hashable {
    var countOfDaily: Int
    var dailyCompleted: Int
    var countOfWeekly: Int
    var weeklyCompleted: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(countOfDaily)
        hasher.combine(dailyCompleted)
        hasher.combine(countOfWeekly)
        hasher.combine(weeklyCompleted)
    }
    
    static func == (lhs: WeekStatistic, rhs: WeekStatistic) -> Bool {
        return lhs.dailyCompleted == rhs.dailyCompleted && lhs.dailyCompleted == rhs.dailyCompleted && lhs.countOfWeekly == rhs.countOfWeekly && lhs.weeklyCompleted == rhs.weeklyCompleted
    }
}

// MARK: - SurveyResponseModel
struct SurveyResponseModel: Decodable, Hashable {
    var isSkipped: Bool
    var isExist: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(isSkipped)
        hasher.combine(isExist)
    }
    
    static func == (lhs: SurveyResponseModel, rhs: SurveyResponseModel) -> Bool {
        lhs.isSkipped == rhs.isSkipped
    }
}

struct SurveyModel: Hashable {
    var isSkipped: Bool
    var isExist: Bool
    var type: SurveyType
    
    init(survey: SurveyResponseModel, type: SurveyType) {
        self.isSkipped = survey.isSkipped
        self.isExist = survey.isExist
        self.type = type
    }
    
    static func == (lhs: SurveyModel, rhs: SurveyModel) -> Bool {
        return lhs.type == rhs.type
    }
}
