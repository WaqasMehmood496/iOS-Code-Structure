//
//  AdviseModel.swift
//  Evexia
//
//  Created by admin on 01.10.2021.
//

import Foundation

// MARK: - AdviseType
enum AdviseType: String, Decodable {
    case email = "EMAIL"
    case url = "URL"
    case tel = "TEL"
}

// MARK: - AdviseModel: Decodable
// TODO: add Coding Key for imageURL
struct AdviseModel: Decodable {
    let id: String
    let title: String
    let type: AdviseType
    let value: String
    let imageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case type
        case value
        case imageURL
    }
}

// MARK: AdviseModel: Hashable
extension AdviseModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
