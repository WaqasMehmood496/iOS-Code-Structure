//
//  PickerBuilder.swift
//  Evexia
//
//  Created by  Artem Klimov on 23.07.2021.
//

import Foundation

class PickerBuilder {
        static func build(viewStyle: [PickerDataModel], defaultSelected: String? = nil, dataClouser: ((String) -> Void)?) -> PickerVC {
            let vc = PickerVC.board(name: .picker)
            let defaultSelection: PickerDataModel? = defaultSelected == nil ? nil : PickerDataModel(title: defaultSelected ?? "")
            let viewModel = PickerVM(dataSource: viewStyle, defaultSelected: defaultSelection, dataClouser: dataClouser)
            
            vc.viewModel = viewModel
            return vc
        }
}
