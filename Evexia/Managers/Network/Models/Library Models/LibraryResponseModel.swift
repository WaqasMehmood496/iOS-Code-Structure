//
//  LibraryResponseModel.swift
//  Evexia
//
//  Created by admin on 05.10.2021.
//

import Foundation

struct LibraryResponseModel: Decodable {
    var data: [ContentModel]
    var isLastPage: Bool
}

class ContentModel: Decodable {
    var id: String
    var type: [Focus]
    var title: String
    var fileUrl: String
    var fileType: ContentType
    var author: AuthorModel
    var createdAt: Double
    var placeholder: String
    var duration: String
    var isFavorite: Bool

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case type
        case title
        case fileUrl
        case fileType
        case author
        case placeholder
        case createdAt
        case duration
        case isFavorite
    }
    
    init(id: String, type: [Focus], title: String, fileUrl: String, fileType: ContentType, author: AuthorModel, createdAt: Double, placeholder: String, duration: String, isFavorite: Bool) {
        self.id = id
        self.type = type
        self.title = title
        self.fileUrl = fileUrl
        self.fileType = fileType
        self.author = author
        self.createdAt = createdAt
        self.placeholder = placeholder
        self.duration = duration
        self.isFavorite = isFavorite
    }
}

extension ContentModel: Hashable {
    static func == (lhs: ContentModel, rhs: ContentModel) -> Bool {
        return lhs.id == lhs.id && lhs.type == lhs.type && lhs.title == lhs.title && lhs.fileUrl == lhs.fileUrl && lhs.isFavorite == lhs.isFavorite
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(type)
        hasher.combine(title)
        hasher.combine(fileUrl)
        hasher.combine(isFavorite)
    }
}

struct AuthorModel: Decodable {
    var id: String
    var username: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case username
    }
}

enum ContentType: String, Codable {
    case video = "WATCH"
    case audio = "LISTEN"
    case pdf = "READ"
}
