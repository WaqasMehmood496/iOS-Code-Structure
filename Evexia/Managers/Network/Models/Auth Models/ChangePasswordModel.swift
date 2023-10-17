//
//  ChangePasswordModel.swift
//  Evexia
//
//  Created by  Artem Klimov on 26.08.2021.
//

import Foundation

struct ChangePasswordModel: Codable {
    var oldPassword: String
    var newPassword: String
    var confirmPassword: String
}
