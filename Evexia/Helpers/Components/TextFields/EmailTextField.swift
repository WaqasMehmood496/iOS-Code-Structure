//
//  EmailTextField.swift
//  Evexia Staging
//
//  Created by  Artem Klimov on 25.06.2021.
//

import Foundation
import UIKit
import Combine

class EmailTextField: BaseTextField {
    
    var isValidInput = PassthroughSubject<Bool, Never>()

    override var fieldState: TextFieldState {
        didSet {
            self.rightViewButton.isHidden = self.fieldState != .error
        }
    }
    
    override func defaultInit() {
        super.defaultInit()
        self.showRightButton = true
        self.keyboardType = .emailAddress
        self.configrightViewButton()
        addTarget(self, action: #selector(validation), for: .editingDidEnd)
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        let inset = UIEdgeInsets(top: 31.0, left: 20.0, bottom: 9.0, right: self.rightViewButton.frame.width + 16.0)
        return bounds.inset(by: inset)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        let inset = UIEdgeInsets(top: 31.0, left: 20.0, bottom: 9.0, right: self.rightViewButton.frame.width + 16.0)
        return bounds.inset(by: inset)
    }

    private func configrightViewButton() {
        self.rightViewButton.isHidden = true
        self.rightViewButton.setImage(UIImage(named: "close_circle"), for: .normal)
        self.rightViewButton.addTarget(self, action: #selector(rightButtonAction(_:)), for: .touchUpInside)
    }
    
    @objc
    private func rightButtonAction(_ sender: UIButton) {
        self.becomeFirstResponder()
        self.text = ""
    }
    
    @objc
    func validation() {
        if self.text?.isEmpty ?? false {
            self.setState(for: .normal)
            self.isValidInput.send(true)
        } else {
            if (self.text ?? "").isValidEmail {
                self.setState(for: .valid)
                self.isValidInput.send(true)
            } else {
                self.setState(for: .error)
                self.isValidInput.send(false)
            }
        }
    }
}
