//
//  UserAuthModel.swift
//  Evexia
//
//  Created by  Artem Klimov on 24.06.2021.
//

import Foundation

struct UserAuthModel: Codable {
    var email: String
    var password: String
    var fbToken: String
}
