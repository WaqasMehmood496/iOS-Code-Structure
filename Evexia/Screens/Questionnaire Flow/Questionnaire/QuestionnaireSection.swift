//
//  QuestionnaireSection.swift
//  Evexia
//
//  Created by admin on 24.09.2021.
//

import Foundation
import UIKit
import Combine

// MARK: - Value Types
typealias QuestionnaireDataSource = UITableViewDiffableDataSource<QuestionnaireSection, QuestionnaireSectionDataType>
typealias QuestionnaireSnaphot = NSDiffableDataSourceSnapshot<QuestionnaireSection, QuestionnaireSectionDataType>

class QuestionnaireSection: Hashable {
    var id = UUID()

    var question: QuestionModel
    var type: QuestionnaireSectionType
    var data: [QuestionnaireSectionDataType]
        
    init(title: QuestionnaireSectionType, data: [QuestionnaireSectionDataType], question: QuestionModel) {
        self.type = title
        self.data = data
        self.question = question
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: QuestionnaireSection, rhs: QuestionnaireSection) -> Bool {
        lhs.id == rhs.id
    }
}

enum QuestionnaireSectionType: String {
    case radio
    case range
}

enum QuestionnaireSectionDataType: Hashable {
    case radio(AnswerModel)
    case range(QuestionModel)
    
    static func == (lhs: QuestionnaireSectionDataType, rhs: QuestionnaireSectionDataType) -> Bool {
        switch (lhs, rhs) {
        case let (.radio(lhsR), .radio(rhsR)):
            return lhsR == rhsR
        case let (.range(lhsP), .range(rhsP)):
            return lhsP == rhsP
        default:
            return false
        }
    }
    
}
