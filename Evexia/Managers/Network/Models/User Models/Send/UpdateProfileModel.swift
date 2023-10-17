//
//  UpdateProfileModel.swift
//  Evexia
//
//  Created by  Artem Klimov on 30.07.2021.
//

import Foundation

struct UpdateProfileModel: Codable {
    var email: String
    var firstName: String
    var lastName: String
    var country: String
    var gender: String
    var height: String
    var sleep: String
    var heartRate: Int?
    var age: String
    
    init(userModel: User) {
        email = userModel.email
        firstName = userModel.firstName
        lastName = userModel.lastName
        country = userModel.country
        gender = userModel.gender?.rawValue ?? ""
        height = userModel.height
        sleep = userModel.sleep
        heartRate = userModel.heartRate
        age = userModel.age
    }
    init(email: String, firstName: String, lastName: String, country: String, gender: String, height: String, sleep: String, heartRate: Int?, age: String) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.country = country
        self.gender = gender
        self.height = height
        self.sleep = sleep
        self.heartRate = heartRate
        self.age = age
    }
}
