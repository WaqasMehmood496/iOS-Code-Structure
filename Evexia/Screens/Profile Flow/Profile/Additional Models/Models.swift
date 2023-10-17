//
//  Models.swift
//  Evexia
//
//  Created by  Artem Klimov on 18.08.2021.
//

import Foundation

enum ProfileType {
    case weight
    case sleep
    case score
    case steps
    case impact
}

enum ProfileStatistic {
    case weight(value: String)
    case sleep(value: String)
    case score(value: String)
    case steps(value: String)
    case impact(value: String)
    
    var title: String {
        switch self {
        case .weight:
            return "Weight".localized()
        case .sleep:
            return "Hours of sleep".localized()
        case .score:
            return "Wellbeing score".localized()
        case .steps:
            return "Steps".localized()
        case .impact:
            return ""
        }
    }
    
    var value: String {
        switch self {
        case let .weight(value):
            return value
        case let .sleep(value):
            return value
        case let .score(value):
            return value
        case let .steps(value):
            return value
        case let .impact(value):
            return value
        }
    }
    
    var measure: String {
        switch self {
        case .weight:
            return "kg"
        case .sleep:
            return "h"
        case .score, .steps, .impact:
            return ""
        }
    }
    
    var focus: Focus {
        switch self {
        case .weight:
            return .eat
        case .sleep:
            return .feel
        case .score:
            return .connect
        case .steps:
            return .move
        case .impact:
            return .move
        }
    }
    
    var type: ProfileType {
        switch self {
        case .weight(_):
            return .weight
        case .sleep(_):
            return .sleep
        case .score(_):
            return .score
        case .steps(_):
            return .steps
        case .impact(_):
            return .impact
        }
    }
}

extension ProfileStatistic: Hashable {
    
}

enum ProfileSettings: CaseIterable {
    case benefits
    case advise
    
    var title: String {
        switch self {
        case .benefits:
            return "Benefits".localized()
        case .advise:
            return "Advice and Support".localized()
        }
    }
}

enum ProfileCellContentType {
    case user(content: User?)
    case statistic(content: ProfileStatisticCellModel)
    case devices
    case settings(content: [ProfileSettings])
    case achievments
    case personalDevelopment(SelfDevelopment)
}

extension ProfileCellContentType: Hashable {
    static func == (lhs: ProfileCellContentType, rhs: ProfileCellContentType) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

struct ProfileStatisticCellModel: Hashable {
    var userName: String
    var calories: String?
    var lastUpdate: Double?
    var statistic: [ProfileStatistic]
}

enum SelfDevelopment {
    case development
    case coaching
    case achievments
    
    var imageKey: String {
        switch self {
        case .development:
            return "graduation_hat"
        case .coaching:
            return "handshake"
        case .achievments:
            return "achievmentsIcon"
            
        }
    }
    
    var title: String {
        switch self {
        case .development:
            return "Personal Development"
        case .coaching:
            return "Coaching"
        case .achievments:
            return "Achievements"
            
        }
    }
    
}
