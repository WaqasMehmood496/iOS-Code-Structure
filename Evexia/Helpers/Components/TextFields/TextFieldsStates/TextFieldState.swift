//
//  TextFieldState.swift
//  Evexia Staging
//
//  Created by  Artem Klimov on 07.07.2021.
//

import Foundation
import UIKit

enum TextFieldState {
    case normal
    case valid
    case editing
    case error
    case active
    
    var style: Style {
        switch self {
        case .normal, .valid, .editing:
            return Style(borderWidth: 1.0, borderColor: .gray8F, backgroundColor: .white, placeholderHeight: 14.0, placeholderColor: .gray8F)
        case .active:
            return Style(borderWidth: 2.0, borderColor: .orange, backgroundColor: .white, placeholderHeight: 14.0, placeholderColor: .gray8F)
        case .error:
            return Style(borderWidth: 2.0, borderColor: .error, backgroundColor: UIColor(displayP3Red: 251.0 / 255.0, green: 237.0 / 255.0, blue: 237.0 / 255.0, alpha: 1.0), placeholderHeight: 14.0, placeholderColor: .error)
        }
    }
    
    struct Style {
        let borderWidth: CGFloat
        let borderColor: UIColor
        let backgroundColor: UIColor
        let placeholderHeight: CGFloat
        let placeholderColor: UIColor
    }
}

enum ConfirmPasswordState {
    case normal
    case valid
    case notValid
    case notMatch
    
    var fieldState: TextFieldState {
        switch self {
        case .normal:
            return .normal
        case .notMatch, .notValid:
            return .error
        case .valid:
            return .valid
        }
    }
    
    var text: String? {
        switch self {
        case .notMatch:
            return "Both passwords must match".localized()
        case .notValid:
            return "Your password must contain at least 1 lower case, 1 upper case character, 1 special symbol, 1 number, min length - 8, only Latin symbols".localized()
        case .valid, .normal:
            return nil
        }
    }
}
