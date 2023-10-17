//
//  AdditionalModels.swift
//  Evexia
//
//  Created by  Artem Klimov on 21.07.2021.
//

import Foundation

enum Days: String, CaseIterable, Comparable {
    
    case mon
    case tue
    case wed
    case thu
    case fri
    case sat
    case sun
    
    var title: String {
        switch self {
        case .mon:
            return "Mon".localized()
        case .tue:
            return "Tue".localized()
        case .wed:
            return "Wed".localized()
        case .thu:
            return "Thu".localized()
        case .fri:
            return "Fri".localized()
        case .sat:
            return "Sat".localized()
        case .sun:
            return "Sun".localized()
        }
    }
}
