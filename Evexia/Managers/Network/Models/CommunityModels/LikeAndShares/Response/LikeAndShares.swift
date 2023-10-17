//
//  LikeAndShares.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 09.09.2021.
//

import Foundation

struct LikePost: Decodable {
    let _id: String
    let isLiked: Bool
}

struct LikeAndShares: Decodable, Hashable {
    
    let firstName: String
    let lastName: String
    let avatar: Avatar?
}
