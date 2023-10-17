//
//  DeepLinksKeys.swift
//  Evexia
//
//  Created by  Artem Klimov on 21.07.2021.
//

import Foundation

enum DeepLinkModel {
    case forgotPassword(token: String)
    case verification(token: String)
    case dashBoard
    case wellbeingQuestionare
    case pulseQuestionare
    case diary
    
}

enum DeepLinksKeys: String, CaseIterable {
    case forgotPassword = "forgot-password"
    case verification = "verification"
    case wellbeing
    case pulse
    
    func generateDeepLinkModel(token: String = "") -> DeepLinkModel {
        switch self {
        case .forgotPassword:
            return .forgotPassword(token: token)
        case .verification:
            return .verification(token: token)
        case .wellbeing:
            return .wellbeingQuestionare
        case .pulse:
            return .pulseQuestionare
        }
    }
}
