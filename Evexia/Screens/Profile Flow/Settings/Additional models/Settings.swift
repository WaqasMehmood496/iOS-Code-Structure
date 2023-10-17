//
//  Settings.swift
//  Evexia
//
//  Created by  Artem Klimov on 09.08.2021.
//

import Foundation
import UIKit

enum Settings {
    case termsOfUse
    case privacyPolicy
    case helpCenter
    case contacts
    case darkMode
    case passwordCahnge
    case logout
    case delete
    case gamefication
    case faceTouchId
    case measurementSystem
    
    var title: String {
        switch self {
        case .termsOfUse:
            return "Terms of use".localized()
        case .privacyPolicy:
            return "Privacy policy".localized()
        case .helpCenter:
            return "Help center".localized()
        case .contacts:
            return "Contact support".localized()
        case .darkMode:
            return "Dark mode".localized()
        case .passwordCahnge:
            return "Password change".localized()
        case .logout:
            return "Log out".localized()
        case .delete:
            return "Delete my account".localized()
        case .gamefication:
            return "Achievements and streaks"
        case .faceTouchId:
            return "Add Biometric".localized()
        case .measurementSystem:
            return "Measurement system".localized()
        }
    }
    
    var accent: UIColor {
        switch self {
        case .delete, .logout:
            return .error
        default:
            return .gray900
        }
    }
}

extension Settings: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.title)
    }
}
