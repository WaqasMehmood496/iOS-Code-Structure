//
//  SetPasswordModel.swift
//  Evexia
//
//  Created by  Artem Klimov on 07.07.2021.
//

import Foundation

struct ResetPasswordModel: Codable {
    var fbToken: String
    var token: String
    var password: String
}
