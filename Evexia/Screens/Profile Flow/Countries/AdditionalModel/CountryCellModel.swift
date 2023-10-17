//
//  CountryCellModel.swift
//  Evexia
//
//  Created by  Artem Klimov on 09.08.2021.
//

import Foundation

class CountryCellModel {
    var country: String
    var isSelected: Bool
    
    init(country: String, isSelected: Bool) {
        self.country = country
        self.isSelected = isSelected
    }
}
