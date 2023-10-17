//
//  CommunityUser.swift
//  Evexia
//
//  Created by admin on 23.05.2022.
//

import Foundation

struct CommunityUser: Decodable, Hashable {
    let id: String
    let username: String
    let avatar: Avatar
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case username
        case avatar
    }
}
