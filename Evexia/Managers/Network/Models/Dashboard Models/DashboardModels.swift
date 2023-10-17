//
//  DashboardModels.swift
//  Evexia
//
//  Created by Oleg Pogosian on 18.01.2022.
//

import Foundation
import UIKit

// MARK: - DashboardResponseModel
struct DashboardResponseModel: Decodable, Hashable {
    var weekProgress: ProgressResponseModel
    var allProgress: [WeelbeingStatisticReponseModel]
    var achievements: Achievements
    
    static func == (lhs: DashboardResponseModel, rhs: DashboardResponseModel) -> Bool {
        lhs.allProgress == rhs.allProgress
    }
}

// MARK: - Achievements
struct Achievements: Decodable, Hashable {
    var streaks: Streaks
    var budges: Budges
    var availableBreaks: Int
    
    static func == (lhs: Achievements, rhs: Achievements) -> Bool {
        lhs.availableBreaks == rhs.availableBreaks
    }
}

// MARK: - Budges
struct Budges: Decodable, Hashable {
    var dailyTasks: DailyTasks
    var steps: DailyTasks
    
    static func == (lhs: Budges, rhs: Budges) -> Bool {
        lhs.steps == rhs.steps
    }
}

// MARK: - DailyTasks
struct DailyTasks: Decodable, Hashable {
    var goal, score: Int
    var icon: String
    
    static func == (lhs: DailyTasks, rhs: DailyTasks) -> Bool {
        lhs.goal == rhs.goal
    }
}

// MARK: - Streaks
struct Streaks: Decodable, Hashable {
    var dailyTasks: StepsClass?
    var steps: StepsClass?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(dailyTasks)
        hasher.combine(steps)
    }
    
    static func == (lhs: Streaks, rhs: Streaks) -> Bool {
        lhs.steps == rhs.steps
    }
}

// MARK: - StepsClass
struct StepsClass: Decodable, Hashable {
    var personalRecord: Int
    var score: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(personalRecord)
        hasher.combine(score)
    }
    
    static func == (lhs: StepsClass, rhs: StepsClass) -> Bool {
        lhs.score == rhs.score && lhs.personalRecord == rhs.personalRecord
    }
}

// MARK: - BadgeSliderModel
struct BadgeSliderModel: Decodable, Hashable {
    let goal: Int
    let score: Int
    let icon: String?
    var steps: Int?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(goal)
        hasher.combine(score)
        hasher.combine(icon)
    }
    
    static func == (lhs: BadgeSliderModel, rhs: BadgeSliderModel) -> Bool {
        lhs.score == rhs.score
    }
}

// MARK: - TakeBreakResponse

struct TakeBreakResponse: Decodable, Hashable {
    let availableBreaks: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(availableBreaks)
    }
}

// MARK: - BreaksType
enum BreaksType: String {
    case steps = "STEPS_STREAK"
    case dailyTasks = "DAILY_TASKS_STREAK"
}
