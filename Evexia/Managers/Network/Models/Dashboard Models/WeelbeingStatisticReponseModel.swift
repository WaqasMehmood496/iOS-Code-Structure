//
//  WeelbeingStatisticReponseModel.swift
//  Evexia
//
//  Created by admin on 19.09.2021.
//

import Foundation

struct ProgressModel: Decodable, Hashable {
    var total: Int
    var completed: Int
    
    var value: Double {
        return  Double(completed) / Double(total)
    }
}

class FocusStatisticModel: Hashable {

    var value: Double
    var type: Focus
    var inactive: Bool
    
    init(progress: ProgressModel, type: Focus) {
        self.type = type

        if progress.value.isNaN || progress.value == 0.0 {
            self.value = 1.0
            self.inactive = true
        } else {
            self.value = progress.value
            self.inactive = false
        }
    }
    
    static func == (lhs: FocusStatisticModel, rhs: FocusStatisticModel) -> Bool {
        lhs.value == rhs.value
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
    
}

struct WeelbeingStatisticReponseModel: Decodable, Hashable {
    var date: String
    var eat: ProgressModel
    var move: ProgressModel
    var connect: ProgressModel
    var feel: ProgressModel
    
    static func == (lhs: WeelbeingStatisticReponseModel, rhs: WeelbeingStatisticReponseModel) -> Bool {
        lhs.date == rhs.date
    }
    
}

class WeelbeingStatisticModel: Hashable {
    var date: String
    var eat: FocusStatisticModel
    var move: FocusStatisticModel
    var disconnect: FocusStatisticModel
    var feel: FocusStatisticModel
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
    }
    
    init(model: WeelbeingStatisticReponseModel) {
        self.date = model.date
        self.eat = FocusStatisticModel(progress: model.eat, type: .eat)
        self.move = FocusStatisticModel(progress: model.move, type: .move)
        self.disconnect = FocusStatisticModel(progress: model.connect, type: .connect)
        self.feel = FocusStatisticModel(progress: model.feel, type: .feel)
    }
    
    init(date: String) {
        self.date = date
        self.eat = FocusStatisticModel(progress: ProgressModel(total: 0, completed: 0), type: .eat)
        self.move = FocusStatisticModel(progress: ProgressModel(total: 0, completed: 0), type: .move)
        self.disconnect = FocusStatisticModel(progress: ProgressModel(total: 0, completed: 0), type: .connect)
        self.feel = FocusStatisticModel(progress: ProgressModel(total: 0, completed: 0), type: .feel)
    }
    
    static func == (lhs: WeelbeingStatisticModel, rhs: WeelbeingStatisticModel) -> Bool {
        lhs.date == rhs.date
    }
    
}
