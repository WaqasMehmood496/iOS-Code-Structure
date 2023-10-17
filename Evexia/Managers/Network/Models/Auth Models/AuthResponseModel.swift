//
//  AuthResponseModel.swift
//  Evexia Staging
//
//  Created by  Artem Klimov on 29.06.2021.
//

import Foundation

struct AuthResponseModel: Codable {
    var accessToken: String
    var refreshToken: String

    var user: User
}
