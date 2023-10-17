//
//  AdditionalModels.swift
//  Evexia
//
//  Created by admin on 07.09.2021.
//

import Foundation
import Combine

// MARK: - DiaryTaskCellModel
final class DiaryTaskCellModel: Hashable {
    var timestamp: Double
    var id: String
    var description: String
    var focus: Focus
    var periodic: String
    var status: TaskStatus
    var isSelected: CurrentValueSubject<Bool, Never>
    var isEditing = CurrentValueSubject<Bool, Never>(false)

    init(timestamp: Double, id: String, description: String, focus: Focus, periodic: String, status: TaskStatus, isSelected: Bool) {
        self.timestamp = timestamp
        self.id = id
        self.description = description
        self.focus = focus
        self.periodic = periodic
        self.status = status
        self.isSelected = CurrentValueSubject<Bool, Never>(isSelected)
    }
    
    static func == (lhs: DiaryTaskCellModel, rhs: DiaryTaskCellModel) -> Bool {
        return lhs.description == rhs.description && lhs.focus == rhs.focus
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(description)
    }
}
