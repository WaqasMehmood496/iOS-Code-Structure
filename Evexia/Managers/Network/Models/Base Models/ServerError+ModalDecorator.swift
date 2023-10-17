//
//  ServerError+ModalDecorator.swift
//  Evexia
//
//  Created by  Artem Klimov on 07.07.2021.
//

import Foundation
import UIKit

extension ErrorCode: ModalAlertDecorator {
    var alert: ModalAlertController {
        switch self {
        case .dissabledPostingAndCommenting:
            let title = """
                            Your posting/commenting abilities are currently turned off by admin
                            Please contact support to get more info
                        """
            let alert = ModalAlertController(title: title, message: nil)
            alert.cancelable = true
            return alert
        case .emailAlreadyTakenSocial:
            let message = "Try another way to sign in or contact support"
            let title = "This email address is already taken".localized()
            let alert = ModalAlertController(title: title, message: message)
            alert.cancelable = true
            return alert
        case .notVerifyedUser:
            let message = "This user is not yet verified. Please check your inbox and junk. Alternatively contact support".localized()
            let title = "User not verified".localized()
            let alert = ModalAlertController(title: title, message: message)
            alert.cancelable = true
            return alert
        case .ivalidVerificationToken:
            let message = "Something has gone wrong. Invalid verification token!. If it continues please contact support".localized()
            let title = "Invalid token".localized()
            let alert = ModalAlertController(title: title, message: message)
            alert.cancelable = true
            return alert
        case .verificationTokenExpired:
            let message = "The verification link has been expired, please try again or contact support!".localized()
            let title = "Link has expired".localized()
            let alert = ModalAlertController(title: title, message: message)
            alert.cancelable = true
            return alert
        case .notValidCredentials:
            let message = "This email or password is incorrect! Please try again.Contact support if it persists".localized()
            let title = "Email or password is incorrect!".localized()
            let alert = ModalAlertController(title: title, message: message)
            alert.cancelable = true
            return alert
        case .blockedUser:
            let message = "This user has been blocked, please contact support for additional information!".localized()
            let title = "User blocked".localized()
            let alert = ModalAlertController(title: title, message: message)
            alert.cancelable = true
            return alert
        case .notValidEmail:
            let message = "This email is not valid, please try again!".localized()
            let title = "Email address is not valid".localized()
            let alert = ModalAlertController(title: title, message: message)
            alert.cancelable = true
            return alert
        case .notValidPassword:
            let message = "The minimum password length is 8 characters, please try again!".localized()
            let title = "Password error".localized()
            let alert = ModalAlertController(title: title, message: message)
            alert.cancelable = true
            return alert
        case .recoveryTokenInvalid:
            let message = "This recovery token is invalid, please try again or contact support if the issue persists!".localized()
            let title = "Invalid token".localized()
            let alert = ModalAlertController(title: title, message: message)
            alert.cancelable = true
            return alert
        case .networkError:
            let message = "Network error, please refresh and try again".localized()
            let title = "Something went wrong".localized()
            let alert = ModalAlertController(title: title, message: message)
            alert.cancelable = true
            return alert
        case .userAlreadyExist:
            let message = "We already have somebody using these credentials. Please contact support".localized()
            let title = "This user already exists".localized()
            let alert = ModalAlertController(title: title, message: message)
            alert.cancelable = true
            return alert
        case .networkConnectionError:
            let message = "Make sure your device is connected to the internet".localized()
            let title = "No internet connection".localized()
            let alert = ModalAlertController(title: title, message: message)
            alert.cancelable = true
            return alert
        case .jsonParseError:
            let message = "".localized()
            let title = "Internal Server Error, please try again later".localized()
            let alert = ModalAlertController(title: title, message: message)
            alert.cancelable = true
            return alert
        case .emailAlreadyTaken:
            let message = "This email address is already taken, please try again or contact support".localized()
            let title = "This email address is already taken".localized()
            let alert = ModalAlertController(title: title, message: message)
            alert.cancelable = true
            return alert
        case .companyNotExist:
            let message = "Check your email address was entered correctly".localized()
            let title = "This company was not recognised".localized()
            let alert = ModalAlertController(title: title, message: message)
            alert.cancelable = true
            return alert
        case .serverError:
            let message = "Request failed with status code 400. Email not added for registration".localized()
            let title = "Server Error".localized()
            let alert = ModalAlertController(title: title, message: message)
            alert.cancelable = true
            return alert
        case .emailNotMatch:
            let message = "The email address does not match any account, please try again or contact support".localized()
            let title = "Email error".localized()
            let alert = ModalAlertController(title: title, message: message)
            alert.cancelable = true
            return alert
        case .differentPassword:
            let message = "Your new password must be different from your previous password".localized()
            let title = "Password Error".localized()
            let alert = ModalAlertController(title: title, message: message)
            alert.cancelable = true
            return alert
        case .notValidtoken:
            let message = "Wrong authentication token, please try again or contact support!".localized()
            let title = "Token Error".localized()
            let alert = ModalAlertController(title: title, message: message)
            alert.cancelable = true
            return alert
            
        case .passwordNotMatch:
            let message = "Your old password is incorrect, please try again or contact support".localized()
            let title = "Password Error".localized()
            let alert = ModalAlertController(title: title, message: message)
            alert.cancelable = true
            return alert
            
        case .rejectSocialForgotPassword:
            let message = "Sorry. Please can you use your social network to sing-in"
            let title = "Network Error".localized()
            let alert = ModalAlertController(title: title, message: message)
            alert.cancelable = true
            return alert
            
        case .emailAlreadyExistsWithAnotherSocialNetwork:
            let message = "Please can use your social network to sing-in".localized()
            let title = "Sign-in Error".localized()
            let alert = ModalAlertController(title: title, message: message)
            alert.cancelable = true
            return alert
        case .noQuestionnaire:
            let message = "There is currently no available questionnaire"
            let title = "No questionnaire".localized()
            let alert = ModalAlertController(title: title, message: message)
            alert.cancelable = true
            return alert
        }
    }
    
    var actionTitle: String? {
        return "Ok".localized()
    }
    
    var dismissTitle: String? {
        return nil
    }
    
    var actionStyle: AlertActionStyle {
        return .normal
    }
    
    var cancelStyle: AlertActionStyle {
        return .normal
    }
    
    var action: (() -> Void)? {
        nil
    }
    
    var isDismissNeeded: Bool {
        false
    }
}
