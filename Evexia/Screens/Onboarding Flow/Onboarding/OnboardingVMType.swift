//
//  OnboardingVMType.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 18.07.2021.
//

import Combine
protocol OnboardingVMType {

    func navigateToPersonalPlan(profileFlow: ProfileEditScreenFlow)
    func navigateToHome()
    func getProjects() -> AnyPublisher<ProjectResponseModel, ServerError> 
}

enum Onboarding: CaseIterable {
    case first
    case second
    case third
    case fourth
    case fifth
    case sixth
    
    var text: String {
        switch self {
        case .first:
            return "Wellbeing begins with us....\nHow we FEEL, EAT, MOVE\nand CONNECT.".localized()
        case .second:
            return "But for our long term\nwellbeing, we need to keep our\nplanet HAPPY & HEALTHY too.".localized()
        case .third:
            return "Which is why with myDay we\ncelebrate our wellbeing\nsuccesses with PLANET POINTS".localized()
        case .fourth:
            return "You get to choose how you earn\nyour planet points:".localized()
        case .fifth:
            return "Your planet points fund\nclimate projects via".localized()
        case .sixth:
            return "Choose how you’d like\nMyDay to work for you:".localized()
        }
    }
    
    var imageKey: String {
        switch self {
        case .first:
            return "onboarding_page_1"
        case .second:
            return "onboarding_page_2"
        case .third:
            return "onboarding_page_3"
        case .fourth:
            return "onboarding_page_1"
        case .fifth:
            return "onboarding_page_2"
        case .sixth:
            return "onboarding_page_3"
        }
    }
}
