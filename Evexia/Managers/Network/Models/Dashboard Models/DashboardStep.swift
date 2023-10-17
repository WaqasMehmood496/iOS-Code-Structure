//
//  DashboardStep.swift
//  Evexia
//
//  Created by Oleksand Kovalov on 01.03.2022.
//

import Foundation

struct DashboardStep: Codable {
    let date: String
    let value: Double
    
    init(stats: Stats) {
        let dateFormatter = DateFormatter()
        var pattern = "dd-MM-yyyy"
        dateFormatter.dateFormat = pattern
        let oldDate = dateFormatter.date(from: stats.date) ?? Date()
        pattern = "yyyy-MM-dd"
        dateFormatter.dateFormat = pattern
        
        date = dateFormatter.string(from: oldDate)
        value = Double(stats.score) ?? 0
    }
}

struct LeaderboardSteps: Codable {
    let date: String
    let value: Int
    
    init(stats: Stats) {
        let dateFormatter = DateFormatter()
        var pattern = "dd-MM-yyyy"
        dateFormatter.dateFormat = pattern
        let oldDate = dateFormatter.date(from: stats.date) ?? Date()
        
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = .current
        pattern = "yyyy-MM-ddTHH:mm:ss.SSSZ"
        let newDate = formatter.string(from: oldDate)
        date = newDate
        value = Int(Double(stats.score) ?? 0)
    }
}

struct StepsResponseModel: Decodable {
    let stepsSyncDate: String
    let stepsBudges: StepsBudges
    let stepsStreaks: StepsStreaks
}

struct StepsBudges: Decodable {
    let goal: Int
    let score: Int
}

struct StepsStreaks: Decodable {
    let personalRecord: Int
    let score: Int
}
