//
//  CommentResponseModel.swift
//  Evexia
//
//  Created by admin on 20.09.2021.
//

import Foundation

struct CommentResponseModel: Decodable, Hashable {
    let _id: String
    var reply: [ReplyModel]
    let content: String
    let author: Author
    let postId: String
    let createdAt: Int
    
    mutating func addReply(reply: ReplyModel) {
        self.reply.append(reply)
    }
}

struct ReplyModel: Decodable, Hashable {
    let _id: String
    let replyTo: ReplyToModel
    let content: String
    let author: Author
    let postId: String
    let createdAt: Int
}

struct ReplyToModel: Codable, Hashable {
    let _id: String
    let username: String
}
