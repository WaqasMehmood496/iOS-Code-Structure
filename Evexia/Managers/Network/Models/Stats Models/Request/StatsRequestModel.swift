//
//  WellbeingRequestModel.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 28.08.2021.
//

import Foundation

struct StatsRequestModel: Codable {
    let type: String
    let dateFrom: Int
    let dateTo: Int
}

enum StatsDateType: Int, Codable {
    case week
    case month
    case year
    case period
    
    var value: String {
        switch self {
        case .month:
            return "month"
        case .week:
            return "week"
        case .year:
            return "year"
        case .period:
            return "period"
        }
    }
    
    var stringFormatForChart: String {
        switch self {
        case .week:
            return "EEE"
        case .month:
            return "dd"
        case .year:
            return "MMM"
        case .period:
            return ""
        }
    }
    
    var stringFormatAPI: String {
        switch self {
        case .week:
            return "MM.dd.yyyy"
        case .month:
            return "MM.dd.yyyy"
        case .year:
            return "MM.yyyy"
        case .period:
            return "MM.dd.yyyy"
        }
    }
    
    func increaseDate(_ date: Date) -> Date {
        switch self {
        case .week:
            return date.plus(days: 1)
        case .month:
            return date.plus(days: 1)
        case .year:
            return date.plus(months: 1)
        case .period:
            return date
        }
    }
}
