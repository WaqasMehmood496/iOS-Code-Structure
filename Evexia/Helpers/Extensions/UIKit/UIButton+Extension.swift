//
//  UIButton+Extension.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 15.09.2021.
//

import UIKit

extension UIButton {
    func changeAlpha(isEnabled: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.alpha = isEnabled ? 1.0 : 0.3
        }
    }
}
