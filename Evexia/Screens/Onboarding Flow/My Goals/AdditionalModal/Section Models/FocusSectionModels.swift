//
//  FocusSectionModels.swift
//  Evexia
//
//  Created by  Artem Klimov on 19.07.2021.
//

import UIKit

// MARK: - Value Types
typealias MyGoalsDataSource = UITableViewDiffableDataSource<FocusSection, MyGoalModel>
typealias MyGoalsSnaphot = NSDiffableDataSourceSnapshot<FocusSection, MyGoalModel>

class FocusSection: Hashable {
    var id = UUID()
    var focus: Focus
    var goals: [MyGoalModel]
    
    init(focus: Focus, goals: [MyGoalModel]) {
        self.focus = focus
        self.goals = goals
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: FocusSection, rhs: FocusSection) -> Bool {
        lhs.id == rhs.id
    }
}
