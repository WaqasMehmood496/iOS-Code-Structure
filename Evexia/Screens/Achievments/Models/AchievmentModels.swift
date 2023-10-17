//
//  AchievmentModels.swift
//  Evexia
//
//  Created by Oleg Pogosian on 06.01.2022.
//

import Foundation
import UIKit

enum TopAchievmentType {
    case steps
    case daysIn
    case completed
    case prescribed
}

enum AchievmentsCellContentType {
    case topAchiev(content: [TopAchievmentsModel])
    case impact
    case exploreAchiev(content: [ExploreAchivmentModel])
    case exploreAchiev20
    case exploreAchiev50
    case exploreAchiev100
    case exploreAchiev175
    case exploreAchiev365
    case steps
}

extension AchievmentsCellContentType: Hashable {
    static func == (lhs: AchievmentsCellContentType, rhs: AchievmentsCellContentType) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

struct TopAchievmentsModel {
    let type: TopAchievmentType
    let count: Int
}

extension TopAchievmentsModel: Hashable {
    static func == (lhs: TopAchievmentsModel, rhs: TopAchievmentsModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

struct ExploreAchivmentModel {
    let descriptionText: String
    let imageName: String
    var count: Int?
    var isActive: Bool
}

extension ExploreAchivmentModel: Hashable {
    static func == (lhs: ExploreAchivmentModel, rhs: ExploreAchivmentModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

// MARK: - AchievmentsResponseModel
struct AchievmentsResponseModel: Codable {
    let daysInTheApp, daysAbove7KSteps, dailyTasksCompleted, dailyTasksPrescribed: Int
    let stepsBadges: Int
    let icons: Icons

    enum CodingKeys: String, CodingKey {
        case daysInTheApp
        case daysAbove7KSteps = "daysAbove7kSteps"
        case dailyTasksCompleted, dailyTasksPrescribed, stepsBadges, icons
    }
}

// MARK: - Icons
struct Icons: Codable {
    let icon20, icon50, icon100, icon175: String
    let icon250, icon365, iconSteps: String

    enum CodingKeys: String, CodingKey {
        case icon20 = "ICON_20"
        case icon50 = "ICON_50"
        case icon100 = "ICON_100"
        case icon175 = "ICON_175"
        case icon250 = "ICON_250"
        case icon365 = "ICON_365"
        case iconSteps = "ICON_STEPS"
    }
}
