//
//  User.swift
//  Evexia
//
//  Created by Yura Yatseyko on 23.06.2021.
//

import Foundation

struct User: Codable, Hashable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.email == rhs.email &&
            lhs.firstName == rhs.firstName &&
            lhs.lastName == rhs.lastName
    }
    
    var email: String
    var firstName: String
    var lastName: String
    var country: String
    var availability: Availability
    var gender: Gender?
    var height: String
    var heartRate: Int?
    var weight: String
    var avatar: Avatar?
    var sleep: String
    var age: String
    var wellbeingScore: String
    var postAbility: Bool
    var isShownAchievements: Bool
    var stepsSyncDate: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.email = try container.decode(String.self, forKey: .email)
        self.stepsSyncDate = try container.decode(String.self, forKey: .stepsSyncDate)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.country = try container.decode(String.self, forKey: .country)
        self.availability = try container.decode(Availability.self, forKey: .availability)
        self.gender = try? container.decodeIfPresent(Gender.self, forKey: .gender)
        self.height = try container.decode(String.self, forKey: .height)
        self.weight = try container.decode(String.self, forKey: .weight)
        self.avatar = try container.decodeIfPresent(Avatar.self, forKey: .avatar)
        self.sleep = try container.decode(String.self, forKey: .sleep)
        self.heartRate = try container.decodeIfPresent(Int.self, forKey: .heartRate)
        self.wellbeingScore = try container.decode(String.self, forKey: .wellbeingScore)
        self.postAbility = try container.decode(Bool.self, forKey: .postAbility)
        self.age = try container.decode(String.self, forKey: .age)
        self.isShownAchievements = try container.decode(Bool.self, forKey: .isShownAchievements)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(email, forKey: .email)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encodeIfPresent(gender, forKey: .gender)
        try container.encode(availability, forKey: .availability)
        try container.encode(country, forKey: .country)
        try container.encode(height, forKey: .height)
        try container.encode(weight, forKey: .weight)
        try container.encodeIfPresent(avatar, forKey: .avatar)
        try container.encode(sleep, forKey: .sleep)
        try container.encodeIfPresent(heartRate, forKey: .heartRate)
        try container.encode(wellbeingScore, forKey: .wellbeingScore)
        try container.encode(postAbility, forKey: .postAbility)
        try container.encode(age, forKey: .age)
        try container.encode(isShownAchievements, forKey: .isShownAchievements)
        try container.encode(stepsSyncDate, forKey: .stepsSyncDate)
    }
    
    enum CodingKeys: String, CodingKey {
        case email
        case firstName
        case lastName
        case country
        case availability
        case gender
        case height
        case heartRate
        case weight
        case avatar
        case sleep
        case age
        case wellbeingScore
        case postAbility
        case isShownAchievements
        case stepsSyncDate
    }
}

struct Availability: Codable, Hashable {
    static func == (lhs: Availability, rhs: Availability) -> Bool {
        return lhs.duration == rhs.duration && lhs.calendar == rhs.calendar
    }
    
    var duration: Int?
    var calendar: AvailabilityCalendar
}

struct AvailabilityCalendar: Codable, Hashable {
    var mon: Int
    var tue: Int
    var wed: Int
    var thu: Int
    var fri: Int
    var sat: Int
    var sun: Int
    
    var dict: [Days: Int] {
        return [.mon: mon, .tue: tue, .wed: wed, .thu: thu, .fri: fri, .sat: sat, .sun: sun]
       
    }
}

struct Avatar: Codable, Hashable {
    var fileUrl: String?
}

struct ShowAchievementsModel: Codable, Hashable {
    var isShownAchievements: Bool
}
