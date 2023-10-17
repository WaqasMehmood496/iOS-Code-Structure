//
//  PersonalDevelopmentCategories Models.swift
//  Evexia Staging
//
//  Created by Oleg Pogosian on 08.12.2021.
//

import Foundation

// MARK: - PersonalDevCategoryElement
struct PersonalDevCategoryElement: Codable {
    let title: String
    let value: Int
}

extension PersonalDevCategoryElement: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}

typealias PersonalDevCategory = [PersonalDevCategoryElement]

// MARK: - PDCategoryDetailsResponseModel
struct PDCategoryDetailsResponseModel: Codable {
    let data: [PDCategoryDetailsModel]
    let total: Int?
    let title: String?
}

// MARK: - PDCategoryDetailsModel
class PDCategoryDetailsModel: Codable {
    let id, title: String
    let videoPlaceholder: VideoPlaceholderModel
    let fileURL: String
    let createdAt, updatedAt: Int
    var isFavorite: Bool

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, videoPlaceholder
        case fileURL = "fileUrl"
        case createdAt, updatedAt, isFavorite
    }
}

extension PDCategoryDetailsModel: Hashable {
    
    static func == (lhs: PDCategoryDetailsModel, rhs: PDCategoryDetailsModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - File
struct VideoPlaceholderModel: Codable {
    let id, fileType: String
    let fileURL: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case fileType
        case fileURL = "fileUrl"
    }
}

extension VideoPlaceholderModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
