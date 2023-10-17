//
//  ParameterTextField.swift
//  Evexia
//
//  Created by  Artem Klimov on 30.07.2021.
//

import Foundation
import Combine
import UIKit



class WeightTextField: BaseTextField {
    
    var isValidInput = PassthroughSubject<Bool, Never>()
    
    override func defaultInit() {
        super.defaultInit()
        keyboardType = .numberPad
        addTarget(self, action: #selector(validation), for: .editingDidEnd)

        if !isMetricSystem {
            setupPicker(components: MeasurementSystemType.us.data.weight)
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
            if (self.text ?? "").isValidWeight {
                self.setState(for: .valid)
                self.isValidInput.send(true)
            } else {
                self.setState(for: .error)
                self.isValidInput.send(false)
            }
        }
    }
}

class MyPickerView: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {

    var didSelectCompletion: Closure1<String>?

    var components: [MetricData] = [] {
        didSet {
            super.delegate = self
            super.dataSource = self
            self.reloadAllComponents()
        }
    }

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return components[component].data.count
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(components[component].data[row]) \(components[component].name)"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let text = "\(components[0].data[selectedRow(inComponent: 0)]).\(components[1].data[selectedRow(inComponent: 1)])"

        didSelectCompletion?(text)
    }

    public var selectedValue: String {
        "\(components[0].data[selectedRow(inComponent: 0)]).\(components[1].data[selectedRow(inComponent: 1)])"
    }
}
