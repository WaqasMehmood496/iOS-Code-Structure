//
//  PickerVM.swift
//  Evexia
//
//  Created by  Artem Klimov on 26.07.2021.
//

import Foundation

enum PlanDuration: Int, CaseIterable {
    case oneWeek = 1
    case twoWeeks
    case threeWeeks
    case fourWeeks
    
    var title: String {
        switch self {
        case .oneWeek:
            return "1 Week"
        case .twoWeeks:
            return "2 Weeks"
        case .threeWeeks:
            return "3 Weeks"
        case .fourWeeks:
            return "4 Weeks"
        }
    }
        
    init?(string: String) {
        guard let type = PlanDuration.allCases.first(where: { $0.title == string })
                else { return nil }
            self = type
        }
}

struct PickerDataModel {
    var title: String
}

class PickerVM {
    
    internal var dataClouser: ((String) -> Void)?
    internal let dataSource: [PickerDataModel]
    internal let defaultSelected: PickerDataModel?
    internal var selected: PickerDataModel?
    
    init(dataSource: [PickerDataModel], defaultSelected: PickerDataModel? = nil, dataClouser: ((String) -> Void)?) {
        self.dataSource = dataSource
        self.defaultSelected = defaultSelected
        self.dataClouser = dataClouser
        self.selected = defaultSelected
    }
    
}
