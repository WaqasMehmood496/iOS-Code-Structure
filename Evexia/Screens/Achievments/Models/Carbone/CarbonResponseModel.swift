//
//  CarbonResponseModel.swift
//  Evexia
//
//  Created by Oleksand Kovalov on 15.02.2022.
//

import Foundation

struct CarboneResponseModel: Decodable {
    let personalTotal: Double
    let totalApp: Double
    let companyTotal: Double
}
