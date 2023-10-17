//
//  DaySliderModel.swift
//  Evexia
//
//  Created by  Artem Klimov on 20.07.2021.
//

import Combine

class DaySliderCellModel {
    var value: CurrentValueSubject<Int, Never>
    
    var day: Days
    
    init(value: Int, day: Days) {
        self.value = CurrentValueSubject(value)
        self.day = day
    }
}

extension DaySliderCellModel: Hashable {
    static func == (lhs: DaySliderCellModel, rhs: DaySliderCellModel) -> Bool {
        return lhs.day == rhs.day && lhs.value.value == rhs.value.value
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(day)
        hasher.combine(value.value)
    }
}
