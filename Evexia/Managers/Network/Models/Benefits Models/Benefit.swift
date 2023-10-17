//
//  Benefit.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 25.08.2021.
//

import Foundation

struct BenefitResponseModel: Decodable {
    let data: [Benefit]
    let total: Int
}

struct Benefit: Decodable {
    let id: String
    let url: String
    let image: ImageResponseModel
    let partner: BenefitPartner
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case url
        case image
        case partner
    }
}

extension Benefit: Hashable {
    static func == (lhs: Benefit, rhs: Benefit) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct ImageResponseModel: Decodable {
    let fileUrl: String
}

struct BenefitPartner: Decodable {
    let title: String
    let avatar: ImageResponseModel
}
