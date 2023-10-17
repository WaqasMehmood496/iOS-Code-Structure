//
//  CommunityRepsonseModel.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 03.09.2021.
//

import UIKit

struct CommunityDailyGoal: Decodable, Hashable {
    let step: String
}

struct Community: Decodable {
    let data: [Post]
    let total: Int
}

struct PostData: Decodable {
    let data: [Post]
}

struct Post: Decodable, Hashable, Equatable {
    let _id: String
    var isLiked: Bool
    let attachments: [Attachments]
    let commentsCounter: Int
    var likes: [String]
    var likesCounter: Int
    let shares: [String]
    let content: String
    let isStatic: Bool
    let isPartnerPost: Bool
    let isCreatedByAdmin: Bool
    let author: Author
    let createdAt: Int
    let video: Attachments?
    let company: Company?
    let partner: Partner?
    let videoPlaceholder: String?
    
    mutating func changeLike(isLiked: Bool) {
        self.isLiked = isLiked
        if isLiked {
            likesCounter += 1
        } else {
            likesCounter -= 1
        }
    }
}

class LocalPost: Hashable {
    static func == (lhs: LocalPost, rhs: LocalPost) -> Bool {
        lhs._id == rhs._id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(_id)
    }
    
    let _id: String
    let attachments: [Attachments]
    let shares: [String]
    let content: String
    let isCreatedByAdmin: Bool
    let author: Author
    let createdAt: Int
    let video: Attachments?
    let company: Company?
    let partner: Partner?
    let videoPlaceholder: String?
    var index: Int = 0
    var image: UIImage?
    var likes: [String]
    var likesCounter: Int
    var isStatic: Bool
    var isPartnerPost: Bool
    var commentsCounter: Int
    var isLiked: Bool
    
    init(post: Post) {
        _id = post._id
        isLiked = post.isLiked
        attachments = post.attachments
        commentsCounter = post.commentsCounter
        likes = post.likes
        likesCounter = post.likesCounter
        shares = post.shares
        content = post.content
        isStatic = post.isStatic
        isPartnerPost = post.isPartnerPost
        isCreatedByAdmin = post.isCreatedByAdmin
        author = post.author
        createdAt = post.createdAt
        video = post.video
        company = post.company
        partner = post.partner
        videoPlaceholder = post.videoPlaceholder
    }
}

struct Partner: Decodable, Hashable {
    let title: String
    let avatar: Avatar
}

struct Author: Decodable, Hashable {
    let _id: String
    let title: String
    let avatar: Avatar?
}

struct Company: Decodable, Hashable {
    let title: String
    let avatar: Avatar
}

struct Attachments: Codable, Hashable {
    let _id: String
    let fileUrl: String
}
