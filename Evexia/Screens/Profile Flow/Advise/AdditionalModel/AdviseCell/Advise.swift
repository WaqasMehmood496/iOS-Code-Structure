//
//  AdviseCellModel.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 18.08.2021.
//

enum Advise {
    case internalHRSupport
    case eap
    case additional
    case sponsor(AdviseModel)
    
    var title: String {
        switch self {
        case .internalHRSupport:
            return "Internal HR Support".localized()
        case .eap:
            return "Employee assistance program".localized()
        case .additional:
            return "Additional Mental Health Services".localized()
        case let .sponsor(advise):
            return advise.title
        }
    }
    
    var imageURL: String? {
        switch self {
        case let .sponsor(model):
            return model.imageURL
        default:
            return nil
        }
    }
}

extension Advise: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}
