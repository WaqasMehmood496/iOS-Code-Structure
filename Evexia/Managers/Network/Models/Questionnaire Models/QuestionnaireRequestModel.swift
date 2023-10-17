//
//  QuestionnaireRequestModel.swift
//  Evexia
//
//  Created by admin on 25.09.2021.
//

import Foundation

// MARK: - QuestionnaireRequestModel: Encodable
struct QuestionnaireRequestModel: Encodable {
    // Questionnaire ID
    var list: [AnswerRequestModel]
}

// MARK: - AnswerRequestModel: Encodable
struct AnswerRequestModel: Encodable {
    // Question ID
    var id: String
    var answerId: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case answerId
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.answerId, forKey: .answerId)
    }
}

// MARK: AnswerRequestModel: Hashable
extension AnswerRequestModel: Hashable {
    
    static func == (lhs: AnswerRequestModel, rhs: AnswerRequestModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}
