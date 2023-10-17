//
//  MyWhyStatements.swift
//  Evexia
//
//  Created by Artem Klimov on 13.07.2021.
//

import Foundation
import Combine

class MyWhyModel {
    let value: Int
    let title: String
    var isSelected: CurrentValueSubject<Bool, Never>
    var selectionAvailabel: CurrentValueSubject<Bool, Never>
    
    init(value: Int, title: String) {
        self.value = value
        self.title = title
        self.isSelected = CurrentValueSubject<Bool, Never>(false)
        self.selectionAvailabel = CurrentValueSubject<Bool, Never>(true)
    }
}

extension MyWhyModel: Hashable {
    static func == (lhs: MyWhyModel, rhs: MyWhyModel) -> Bool {
        return lhs.title == rhs.title
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}
