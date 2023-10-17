//
//  CompleteTaskResponseModel.swift
//  Evexia
//
//  Created by admin on 13.09.2021.
//

import Foundation

struct CompleteTaskRequestModel: Encodable {
    var timestamp: Double
    var taskId: String
//    var status: TaskStatus
}

struct UpdateSelectedTaskRequestModel: Encodable {
    var timestamp: Double
    var tasks: [String]
}

struct CompleteTaskResponseModel: Decodable {
    var data: CompleteStatusModel
    
    struct CompleteStatusModel: Decodable {
        var firstTaskCompleted: Bool
        let dailyTasksReward: DailyTasksReward
    }
}

// MARK: - DailyTasksReward
struct DailyTasksReward: Codable {
    let score, goal: Int
    let goalIcon: String
    let isReceivedAward: Bool?
}
