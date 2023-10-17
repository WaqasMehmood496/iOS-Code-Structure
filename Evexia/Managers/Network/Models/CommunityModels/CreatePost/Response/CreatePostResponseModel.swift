//
//  CreatePostResponseModel.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 10.09.2021.
//

import Foundation

struct CreatePostResponseModel: Decodable {
    let _id: String
    let attachments: [Attachments]
    let video: String
    let comments: [String]
    let commentsCounter: Int
    let likes: [String]
    let shares: [String]
    let content: String
    let isStatic: Bool
    let isPartnerPost: Bool
    let isCreatedByAdmin: Bool
    let author: String
    let company: String
    let createdAt: Int
}
