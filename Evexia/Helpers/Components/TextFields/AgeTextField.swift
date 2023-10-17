//
//  AgeTextField.swift
//  Evexia
//
//  Created by admin on 19.10.2021.
//

import Foundation
import Combine

class AgeTextField: BaseTextField {
    
    var isValidInput = PassthroughSubject<Bool, Never>()
    
    override func defaultInit() {
        super.defaultInit()
        self.keyboardType = .numberPad
        
        addTarget(self, action: #selector(self.validation), for: .editingDidEnd)
    }
    
    @objc
    func validation() {
        if self.text?.isEmpty ?? false {
            self.setState(for: .normal)
            self.isValidInput.send(true)
        } else {
            if (self.text ?? "").isValidAge {
                self.setState(for: .valid)
                self.isValidInput.send(true)
            } else {
                self.setState(for: .error)
                self.isValidInput.send(false)
            }
        }
    }
}
