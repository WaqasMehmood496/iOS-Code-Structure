//
//  ModalAlertViewStyle.swift
//  Evexia
//
//  Created by  Artem Klimov on 07.07.2021.
//

import Foundation
import UIKit

// MARK: - ModalAlertViewStyles
enum ModalAlertViewStyles {
    case deletePost
    case deleteAccount
    case logout
    case success
    case passwordUpdated
    case passwordSet
    case notChangedEditPost
    case rewritePlan
}

// MARK: - ModalAlertDecorator
extension ModalAlertViewStyles: ModalAlertDecorator {
    
    var alert: ModalAlertController {
        switch self {
        case .notChangedEditPost:
            let title = "Are you sure?".localized()
            let message = "All data will be discarded".localized()
            let alert = ModalAlertController(title: title, message: message)
            alert.cancelable = true
            return alert
        case .deletePost:
            let title = "Delete post".localized()
            let message = "Do you really want to delete this posts?".localized()
            let alert = ModalAlertController(title: title, message: message)
            return alert
        case .deleteAccount:
            let title = "There is no going back...".localized()
            let message = "By deleting your account, all of your data disappears forever. Are your sure?".localized()
            let alert = ModalAlertController(title: title, message: message)
            return alert
        case .logout:
            let title = "You want to log out?".localized()
            let message = "Your activity and all your data will be saved until next login.".localized()
            let alert = ModalAlertController(title: title, message: message)
            return alert
        case .success:
            let title = "Success".localized()
            let alert = ModalAlertController(title: title, message: "")
            return alert
        case .passwordUpdated:
            let title = "Your password is successfully updated.".localized()
            let alert = ModalAlertController(title: title, message: "")
            return alert
        case .passwordSet:
            let title = "Your password is successfully recovered.".localized()
            let alert = ModalAlertController(title: title, message: "")
            alert.backgroundViewColor = .greenCA
            alert.dropShadow(radius: 16.0, xOffset: 0.0, yOffset: 2.0, shadowOpacity: 0.5, shadowColor: .black)
            return alert
            
        case .rewritePlan:
            let title = "Would you like to rewrite your plan?".localized()
            let message = "By clicking the rewrite button you will be able to reset all of your preferences for your personal plan"
            let alert = ModalAlertController(title: title, message: message)
            return alert
        }
    }
    
    var actionTitle: String? {
        switch self {
        case .deleteAccount:
            return "Delete account".localized()
        case .deletePost:
            return "Delete post".localized()
        case .logout:
            return "Log out"
        case .rewritePlan:
            return "Rewrite"
        default:
            return "Ok"
        }
    }
    
    var dismissTitle: String? {
        switch self {
        case .deleteAccount:
            return "Cancel".localized()
        case .deletePost:
            return "Cancel".localized()
        case .logout:
            return "Cancel".localized()
        default:
            return nil
        }
    }
    
    var actionStyle: AlertActionStyle {
        switch self {
        case .notChangedEditPost:
            return .highlight
        case .deletePost:
            return .highlight
        case .deleteAccount:
            return .highlight
        case .logout:
            return .highlight
        case .success:
            return .normal
        case .passwordUpdated:
            return .normal
        case .passwordSet:
            return .normal
        case .rewritePlan:
            return .normal
        }
    }
    
    var cancelStyle: AlertActionStyle {
        switch self {
        case .notChangedEditPost:
            return .cancel
        case .deletePost:
            return .cancel
        case .deleteAccount:
            return .cancel
        case .logout:
            return .cancel
        case .success:
            return .cancel
        case .passwordUpdated:
            return .normal
        case .passwordSet:
            return .normal
        case .rewritePlan:
            return .cancel
        }
    }
    
    var action: (() -> Void)? {
        nil
    }
    
    var isDismissNeeded: Bool {
        return false
    }
}
