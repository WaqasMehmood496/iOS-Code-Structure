//
//  Stats.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 30.08.2021.
//

import Foundation
import UIKit

struct Stats {
    let id: UUID = UUID()
    var date: String
    var score: String
    var inactive: Bool
}

extension Stats: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum StatisticType {
    case wellbeing
    case steps
    case weight
    case sleep
    
    var barTint: UIColor {
        switch self {
        case .wellbeing:
            return .connectNew
        case .steps:
            return .moveNew
        case .weight:
            return .eatNew
        case .sleep:
            return .feelNew
        }
    }
    
    var title: String {
        switch self {
        case .wellbeing:
            return "Wellbeing score".localized()
        case .steps:
            return "Steps".localized()
        case .weight:
            return "Weight".localized()
        case .sleep:
            return "Hours of sleep".localized()
        }
    }
}
