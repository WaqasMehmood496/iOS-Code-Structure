//
//  RoundedView.swift
//  Evexia
//
//  Created by  Artem Klimov on 01.07.2021.
//

import UIKit

class RoundedView: UIView {
    
    override func draw(_ rect: CGRect) {
        layer.masksToBounds = true
        layer.cornerRadius = rect.height / 2.0
    }
}
