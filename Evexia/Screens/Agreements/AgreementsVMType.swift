//
//  PrivacyPolicy.swift
//  Evexia
//
//  Created by  Artem Klimov on 05.07.2021.
//

import Foundation

// MARK: - AgreementsVMType
protocol AgreementsVMType {
    func navigateToAgreements(type: Agreements)

    var type: Agreements { get }
}

enum Agreements {
    case termsOfUse
    case privacyPolicy
    
    var text: String {
        switch self {
        case .privacyPolicy:
            return """
            My Day Inc., the provider of the My Day app, has prepared this Privacy Policy to explain what Personal Data (defined below) we collect, how we use and share that data, and your choices concerning our data practices. Our mobile application (the “App”) hosts an online fasting community where users can access resources, set goals, log fasting activity, and track long-term progress (such services, including https://www.evexia.com/ (the “Site”) and the App, are referred to collectively in this Privacy Policy as the “Service”).

            This Privacy Policy explains what Personal Data (defined below) we collect, how we use and share that data, and your choices concerning our data practices. This Privacy Policy is incorporated into and forms part of our <terms>Terms of Service</terms>.

            Before using the Service or submitting any Personal Data to Zero, please review this Privacy Policy carefully and contact us if you have any questions. By using the Service, you agree to the practices described in this Privacy Policy. If you do not agree to this Privacy Policy, please do not access the Site or otherwise use the Service.
            """
        case .termsOfUse:
            return """
            Welcome to My Day. Please read on to learn the rules and restrictions that govern your use of our website(s), products, services and applications (the “Services”). If you have any questions, comments, or concerns regarding these terms or the Services, please contact us at support@evexia.com.

            These Terms of Use (the “Terms”) are a binding contract between you and Big Sky Health, Inc. (“Company,” “we” and “us”). You must agree to and accept all of the Terms, or you don’t have the right to use the Services. Your using the Services in any way means that you agree to all of these Terms, and these Terms will remain in effect while you use the Services. These Terms include the provisions in this document, as well as those in the <privacy>Privacy Policy</privacy>.

            Will these Terms ever change?
            We are constantly trying to improve our Services, so these Terms may need to change along with the Services. We reserve the right to change the Terms at any time, but if we do, we will bring it to your attention by placing a notice on the Services, by sending you an email, and/or by some other means.
            """
        }
    }
    
    var title: String {
        switch self {
        case .privacyPolicy:
            return "Privacy Policy".localized()
        case .termsOfUse:
            return "Terms of Use".localized()
        }
    }
    
    var dateText: String {
        return "Effective date: ".localized() + "May".localized() + " 16, 2021"
    }
    
    var imageKey: String {
        switch self {
        case .privacyPolicy:
            return "terms_of_use"
        case .termsOfUse:
            return "page"
        }
    }
    
}
