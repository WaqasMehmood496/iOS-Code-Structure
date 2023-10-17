//
//  MyGoalModel.swift
//  Evexia
//
//  Created by  Artem Klimov on 19.07.2021.
//

import Foundation
import Combine

class MyGoalModel {
    var id: String
    var title: String
    var isSelected: CurrentValueSubject<Bool, Never>
    var type: Focus
    
    init(id: String, title: String, focus: Focus) {
        self.id = id
        self.title = title
        self.isSelected = CurrentValueSubject<Bool, Never>(false)
        self.type = focus
    }
}

extension MyGoalModel: Hashable {
    static func == (lhs: MyGoalModel, rhs: MyGoalModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
