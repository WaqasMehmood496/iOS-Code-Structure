//
//  CommunityCellContentType.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 03.09.2021.
//

import Foundation

// MARK: - CommunityCellContent
enum CommunityCellContent: Hashable {
    case createPost
    case userPostWithDailyGoal(LocalPost)
    case dailyGoal
    case userPost(LocalPost)
    case partnerPost(LocalPost)
    case company(LocalPost)
    case benefitPost(LocalPost)
    
    init(post: LocalPost) {
        switch post {
        case post where post.isStatic:
            self = .userPostWithDailyGoal(post)
        case post where post.isPartnerPost:
            self = .partnerPost(post)
        case post where post.isCreatedByAdmin && !post.isPartnerPost:
            self = .company(post)
        default: self = .userPost(post)
        }
    }
}
