//
//  Gender.swift
//  Evexia
//
//  Created by  Artem Klimov on 29.07.2021.
//

import Foundation

enum Gender: String, CaseIterable, Codable {
    case female = "Female"
    case male = "Male"
    case binary = "Non - Binary"
    case notSet = "Prefer not to say"
    
    var title: String {
        switch self {
        case .male:
            return "Male".localized()
        case .female:
            return "Female".localized()
        case .binary:
            return "Non - Binary".localized()
        case .notSet:
            return "Prefer not to say".localized()
        }
    }
}
