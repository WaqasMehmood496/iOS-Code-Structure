//
//  CommunityRequestModel.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 09.09.2021.
//

import Foundation

struct CreatePostRequestModel: Codable {
    let attachments: [Attachments]
    let content: String
    let video: Attachments?
    var employees: [String]?
}
