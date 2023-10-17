//
//  RefreshTokenResponseModel.swift
//  Evexia
//
//  Created by  Artem Klimov on 15.08.2021.
//

import Foundation

struct RefreshTokenResponseModel: Codable {
    var accessToken: String
    var refreshToken: String
}
