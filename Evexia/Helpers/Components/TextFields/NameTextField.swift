//
//  NameTextField.swift
//  Evexia
//
//  Created by  Artem Klimov on 03.08.2021.
//

import Foundation
import Combine

class NameTextField: BaseTextField {
    
    var isValidInput = PassthroughSubject<Bool, Never>()
    
    override func defaultInit() {
        super.defaultInit()
        self.showRightButton = true
        self.keyboardType = .alphabet
        
        addTarget(self, action: #selector(validation), for: .editingDidEnd)
    }
    
    @objc
    func validation() {
        if self.text?.isEmpty ?? false {
            self.setState(for: .normal)
            self.isValidInput.send(true)
        } else {
            if (self.text ?? "").isValidName {
                self.setState(for: .valid)
                self.isValidInput.send(true)
            } else {
                self.setState(for: .error)
                self.isValidInput.send(false)
            }
        }
    }
}
