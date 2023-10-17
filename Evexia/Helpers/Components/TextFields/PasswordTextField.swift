//
//  PasswordTextField.swift
//  Evexia Staging
//
//  Created by  Artem Klimov on 25.06.2021.
//

import UIKit

class PasswordTextField: BaseTextField {
    
    override func defaultInit() {
        super.defaultInit()
        self.showRightButton = true
        self.textContentType = .password
        self.isSecureTextEntry = true
        self.clearsOnBeginEditing = true
        self.autocorrectionType = .no
        self.configSecureButton()
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        let inset = UIEdgeInsets(top: 31.0, left: 20.0, bottom: 9.0, right: self.rightViewButton.frame.width + 16.0)
        return bounds.inset(by: inset)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        let inset = UIEdgeInsets(top: 31.0, left: 20.0, bottom: 9.0, right: self.rightViewButton.frame.width + 16.0)
        return bounds.inset(by: inset)
    }

    private func configSecureButton() {
        self.rightViewButton.addTarget(self, action: #selector(self.rightButtonAction(_:)), for: .touchUpInside)
        self.rightViewButton.setImage(UIImage(named: "password_show"), for: .normal)
        self.rightViewButton.setImage(UIImage(named: "password_hide"), for: .selected)
    }
    
    @objc
    private func rightButtonAction(_ sender: UIButton) {
        self.isSecureTextEntry = !isSecureTextEntry
        self.rightViewButton.isSelected = !isSecureTextEntry
    }
}
