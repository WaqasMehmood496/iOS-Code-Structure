//
//  ProfileSettingsModel.swift
//  Evexia
//
//  Created by  Artem Klimov on 28.07.2021.
//

import Foundation

// MARK: - ProfileCellModel
struct ProfileCellModel {
    var value: String
    var type: ProfileSettingsType
}

extension ProfileCellModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.type)
    }
}

// MARK: - ProfileSettingsType
enum ProfileSettingsType: CaseIterable {
    case name
    case email
    case country
    case gender
    case age
    case weight
    case height
    case availability
    case sleep

    static var onboardingSettings: [ProfileSettingsType] {
        return [name, email, country, gender, age, weight, height]
    }
    
    static var editProfileSettings: [ProfileSettingsType] {
        return [name, email, country, gender, age, weight, height, availability]
    }
    
    var title: String {
        switch self {
        case .name:
            return "Name".localized()
        case .email:
            return "Email".localized()
        case .country:
            return "Country".localized()
        case .gender:
            return "Gender".localized()
        case .age:
            return "Age".localized()
        case .weight:
            return "Weight".localized()
        case .height:
            return "Height".localized()
        case .availability:
            return "Availability".localized()
        case .sleep:
            return "Hours of sleep".localized()
        }
    }
}
