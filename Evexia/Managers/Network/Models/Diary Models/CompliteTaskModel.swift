//
//  CompliteTaskModel.swift
//  Evexia
//
//  Created by admin on 10.09.2021.
//

import Foundation

struct TaskRequestModel: Codable {
    var timestamp: Double
    var taskId: String
}

struct CompliteTaskRequestModel: Codable {
    var timestamp: Double
    var taskId: String
//    var status: String
}
