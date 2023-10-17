//
//  DashboardSection.swift
//  Evexia
//
//  Created by admin on 12.09.2021.
//

import Foundation
import UIKit

class DashboardSectionModel: Hashable {
    var id = UUID()
    
    var type: DashboardSectionType
    var breaksCount: Int?
    var data: [DashboardSectionDataType]
    
    init(title: DashboardSectionType, data: [DashboardSectionDataType], breaksCount: Int? = nil) {
        self.type = title
        self.data = data
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DashboardSectionModel, rhs: DashboardSectionModel) -> Bool {
        lhs.id == rhs.id
    }
}

enum DashboardSectionType: String {
    case survey
    case progress
    case moveProgress
    case statistic
    case completedTasks
    case walk
    case slider
}

enum DashboardSectionDataType: Hashable {
    case survey(_: SurveyModel)
    case progress(_: WeekStatistic?)
    case moveProgress(_: [Stats]?)
    case statistic(_: [WeelbeingStatisticModel]?)
    case completedTasks(_ : StepsClass?)
    case walk(_: StepsClass?)
    case slider(_: [BadgeSliderModel]?)
    
    static func == (lhs: DashboardSectionDataType, rhs: DashboardSectionDataType) -> Bool {
        switch (lhs, rhs) {
        case let (.survey(lhsR), .survey(rhsR)):
            return lhsR == rhsR
        case let (.progress(lhsP), .progress(rhsP)):
            return lhsP == rhsP
        case let (.moveProgress(lhsP), .moveProgress(rhsP)):
            return lhsP == rhsP
        case let (.statistic(lhsS), .statistic(rhsS)):
            return lhsS == rhsS
        case let (.completedTasks(lhsS), .completedTasks(rhsS)):
            return lhsS == rhsS
        case let (.walk(lhsS), .walk(rhsS)):
            return lhsS == rhsS
        case let (.slider(lhsS), .slider(rhsS)):
            return lhsS == rhsS
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .survey(models):
            hasher.combine((models))
        case let .progress(models):
            hasher.combine((models))
        case let .moveProgress(models):
            hasher.combine((models))
        case let .statistic(models):
            hasher.combine((models))
        case let .completedTasks(models):
            hasher.combine((models))
        case let .walk(models):
            hasher.combine((models))
        case let .slider(models):
            hasher.combine((models))
        }
    }
}

enum SurveyType: Hashable {
    case wellbeing
    case pulse
    
    var image_key: String {
        switch self {
        case .pulse:
            return "pencil"
        case .wellbeing:
            return "brain"
        }
    }
    
    var title: String {
        switch self {
        case .pulse:
            return "My Day Pulse Survey"
        case .wellbeing:
            return "Wellbeing Questionnaire"
        }
    }
    
    var description: String {
        switch self {
        case .pulse:
            return "Is working from home affecting your health?"
        case .wellbeing:
            return "Completing your questionnaire will assist you in improving your self awareness"
        }
    }
}
