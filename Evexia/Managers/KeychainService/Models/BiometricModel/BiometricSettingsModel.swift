//
//  BiometricSettingsModel.swift
//  Evexia
//
//  Created by admin on 17.10.2022.
//

import Foundation

struct BiometricSettingsModel: Codable {
    var type: BiometricAuthTypeModel
    var access: Bool
}


enum BiometricAuthTypeModel: String, Codable {
    case faceId
    case touchId
    
    var reason: String {
        switch self {
        case .faceId:
            return "biometric.auth.type.enum.face.id.auth.reason"
        case .touchId:
            return "biometric.auth.type.enum.touch.id.auth.reason"
        }
    }
}
