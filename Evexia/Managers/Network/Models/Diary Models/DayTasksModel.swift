//
//  DayTasksModel.swift
//  Evexia
//
//  Created by admin on 06.09.2021.
//

import Foundation

struct SkippedTaskResponseModel: Decodable {
    var data: TaskResponseModel?
}

struct DiaryResponseModel: Decodable {
    let data: DiaryMainModel
}

struct DiaryMainModel: Decodable {
    var diary: [DayTasksResponseModel]?
    let toDate: Int
}

struct SkippedTaskModel: Decodable {
    var id: String
    var status: TaskStatus
    var selected: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case status
        case selected
    }
}

struct UndoTaskResponseModel: Decodable {
    var data: SkippedTaskModel
}

struct DayTasksResponseModel: Decodable {
    var id: String
    var timestamp: Double
    var data: [TaskResponseModel]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case timestamp
        case data
    }
}

struct TaskResponseModel: Decodable {
    var id: String
    var status: TaskStatus
    var selected: Bool?
    var title: String
    var type: Focus
    var duration: Int
    var frequency: String
    var company: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case status
        case selected
        case title
        case type
        case duration
        case frequency
        case company
    }
}

enum TaskStatus: String, Codable {
    case notCompleted = "NOT_COMPLETED"
    case completed = "COMPLETED"
    case overCompleted = "OVER_COMPLETED"

    internal func undo() -> TaskStatus {
        switch self {
        case .completed:
            return .notCompleted
        case .notCompleted:
            return .notCompleted
        case .overCompleted:
            return .completed
        }
    }
}
