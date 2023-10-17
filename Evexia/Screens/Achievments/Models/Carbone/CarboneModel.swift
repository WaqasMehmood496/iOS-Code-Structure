//
//  CarboneModel.swift
//  Evexia
//
//  Created by Oleksand Kovalov on 15.02.2022.
//

import Foundation
import UIKit



enum CarboneModel: Hashable {
    case personalTotal(Double)
    case totalApp(Double)
    case companyTotal(Double)
    
    var title: String {
        switch self {
        case .personalTotal:
            return "My effort reduced"
        case .companyTotal:
            return "My company reduced"
        case .totalApp:
            return "MyDay community reduced"
        }
    }
    
    var subTitle: String {
        switch self {
        case .personalTotal:
            return "CO2 emition"
        case .companyTotal:
            return "CO2 emition"
        case .totalApp:
            return "CO2 emition"
        }
    }
    
    var image: UIImage {
        switch self {
        case .personalTotal:
            return UIImage(named: "image_myEffort_impact")!
        case .companyTotal:
            return UIImage(named: "image_company_impact")!
        case .totalApp:
            return UIImage(named: "image_community_impact")!
        }
    }
    
    var value: Double {
        switch self {
        case .personalTotal(let value):
            return value
        case .totalApp(let value):
            return value
        case .companyTotal(let value):
            return value
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .personalTotal, .companyTotal:
            return .darkBlueNew
        case .totalApp:
            return .white
        }
    }
}

