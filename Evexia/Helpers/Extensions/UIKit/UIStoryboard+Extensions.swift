//
//  UIStoryboard+Extensions.swift
//  Evexia
//
//  Created by Yura Yatseyko on 23.06.2021.
//

import UIKit

protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

extension StoryboardIdentifiable where Self: UIViewController {
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
    
    static func board(name: UIStoryboard.Storyboard) -> Self {
        let storyboard = UIStoryboard(name: name.filename, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as! Self
    }
}

extension UIStoryboard {
    enum Storyboard: String {
        case signIn
        case root
        case signUp
        case verification
        case passwordRecovery
        case recoveryVerification
        case agreements
        case setPassword
        case onboarding
        case onboardingRoot
        case personalPlan
        case myWhy
        case myGoals
        case countries
        case splash
        case myAvailability
        case picker
        case profileEdit
        case setParameter
        case settings
        case advise
        case passwordChange
        case profile
        case benefits
        case personalDevelopment
        case pdCategoryDetails
        case achievments
        case impact
        case measurementSystem
        
        // Community
        case community
        case communityCreateEditPost
        case wellbeing
        case external
        case diaryCalendar
        case diary
        case dashboard
        case likesShared
        case createComment
        case commentsList
        case library
        case questionnaire
        case questionnaireResult
        
        case webView

        var filename: String {
            switch self {
            case .signIn:
                return "SignIn"
            case .root:
                return "Root"
            case .signUp:
                return "SignUp"
            case .verification:
                return "Verification"
            case .passwordRecovery:
                return "PasswordRecovery"
            case .recoveryVerification:
                return "RecoveryVerification"
            case .agreements:
                return "Agreements"
            case .setPassword:
                return "SetPassword"
            case .onboarding:
                return "Onboarding"
            case .onboardingRoot:
                return "OnboardingRoot"
            case .personalPlan:
                return "PersonalPlan"
            case .myWhy:
                return "MyWhy"
            case .myGoals:
                return "MyGoals"
            case .countries:
                return "Countries"
            case .splash:
                return "Splash"
            case .myAvailability:
                return "MyAvailability"
            case .picker:
                return "Picker"
            case .profileEdit:
                return "ProfileEdit"
            case .setParameter:
                return "SetParameter"
            case .settings:
                return "Settings"
            case .advise:
                return "Advise"
            case .passwordChange:
                return "PasswordChange"
            case .profile:
                return "Profile"
            case .benefits:
                return "Benefits"
            case  .personalDevelopment:
                return "PersonalDevelopment"
            case .pdCategoryDetails:
                return "PDCategoryDetails"
            case .community:
                return "Сommunity"
            case .wellbeing:
                return "Wellbeing"
            case .external:
                return "External"
            case .diaryCalendar:
                return "DiaryCalendar"
            case .diary:
                return "Diary"
            case .dashboard:
                return "Dashboard"
            case .communityCreateEditPost:
                return "CreateEditPost"
            case .likesShared:
                return "LikesShared"
            case .createComment:
                return "CreateComment"
            case .commentsList:
                return "CommentsList"
            case .library:
                return "Library"
            case .questionnaire:
                return "Questionnaire"
            case .questionnaireResult:
                return "QuestionnaireResult"
            case .webView:
                return "WebView"
            case .achievments:
                return "Achievments"
            case .impact:
                return "MyImpact"
            case .measurementSystem:
                return "MeasurementSystemVC"
            }
        }
        
        var storyboard: UIStoryboard {
            return UIStoryboard(name: filename, bundle: Bundle.main)
        }
    }
}
