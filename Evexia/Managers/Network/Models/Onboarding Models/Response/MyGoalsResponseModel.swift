//
//  MyGoalsResponseModel.swift
//  Evexia
//
//  Created by  Artem Klimov on 19.07.2021.
//

import Foundation

struct MyGoalsResponseModel: Decodable {
    var _id: String
    var type: Focus
    var title: String
}
