//
//  HeightTextField.swift
//  Evexia
//
//  Created by  Artem Klimov on 30.07.2021.
//

import Foundation
import Combine

class HeightTextField: BaseTextField {
    
    var isValidInput = PassthroughSubject<Bool, Never>()
    
    override func defaultInit() {
        super.defaultInit()
        keyboardType = .numberPad
        addTarget(self, action: #selector(validation), for: .editingDidEnd)

        if !isMetricSystem {
            setupPicker(components: MeasurementSystemType.us.data.height)
            setupPickerAccessory()
        }
    }

    @objc
    func validation() {
        guard isMetricSystem else {
            self.setState(for: .normal)
            self.isValidInput.send(true)
            return
        }
        if self.text?.isEmpty ?? false {
            self.setState(for: .normal)
            self.isValidInput.send(true)
        } else {
            if (self.text ?? "").isValidHeight {
                self.setState(for: .valid)
                self.isValidInput.send(true)
            } else {
                self.setState(for: .error)
                self.isValidInput.send(false)
            }
        }
    }
}
