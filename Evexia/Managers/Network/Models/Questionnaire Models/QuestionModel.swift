//
//  QuestionModel.swift
//  Evexia
//
//  Created by admin on 24.09.2021.
//

import Foundation
import Combine

enum AnswerType: String, Decodable {
    case radio = "RADIO"
    case range = "RANGE"
}

// MARK: - QuestionnaireModel
struct QuestionnaireModel: Decodable {
    var id: String
    var title: String
    var list: [QuestionModel]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case list
    }
}

// MARK: - QuestionModel
class QuestionModel: Decodable {
    var id: String
    var question: String
    var description: String?
    var type: AnswerType
    var answers: [AnswerModel]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case question
        case description = "subtitle"
        case type
        case answers
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.question = try container.decode(String.self, forKey: .question)
        self.type = try container.decodeIfPresent(AnswerType.self, forKey: .type) ?? .radio
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.answers = try container.decode([AnswerModel].self, forKey: .answers)
    }
}

// MARK: - QuestionModel: Hashable
extension QuestionModel: Hashable {
    static func == (lhs: QuestionModel, rhs: QuestionModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - AnswerModel: Decodable
class AnswerModel: Decodable {
    var uuid = UUID()
    var id: String
    var title: String
    var points: Int?
    var isSelected: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case points
        case title
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.points = try container.decodeIfPresent(Int.self, forKey: .points)
        self.title = try container.decode(String.self, forKey: .title)
        self.isSelected = false
    }
    
    init(id: String, title: String, points: Int? = nil, isSelected: Bool = false) {
        self.id = id
        self.title = title
        self.points = points
        self.isSelected = isSelected
    }
}

// MARK: - AnswerModel: Hashable
extension AnswerModel: Hashable {
    static func == (lhs: AnswerModel, rhs: AnswerModel) -> Bool {
        return lhs.uuid == rhs.uuid && lhs.title == rhs.title
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)

    }
}
