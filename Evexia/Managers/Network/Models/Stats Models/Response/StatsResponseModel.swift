//
//  WellbeingResponseModel.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 28.08.2021.
//

import Foundation

struct StatisticResponse: Codable {
    var statistic: [StatsResponseModel]
    var entries: [StatsResponseModel]
}

struct StatsResponseModel: Codable, Hashable {
    var date: String
    let value: String
    var timestamp: Double?
}

struct WellbeingResponse: Codable, Hashable {
    var date: String
    let value: String
}
