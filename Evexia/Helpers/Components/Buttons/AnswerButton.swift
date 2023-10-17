//
//  AnswerButton.swift
//  Evexia
//
//  Created by admin on 25.09.2021.
//

import UIKit

class AnswerButton: UIButton {
    
    override open var isSelected: Bool {
        didSet {
            self.backgroundColor = isSelected ? .orange : .white
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    required init(title: String) {
        super.init(frame: .zero)
        self.backgroundColor = .white
        self.setTitle(title, for: .normal)
        self.setTitleColor(.gray700, for: .normal)
        self.setTitleColor(.white, for: .selected)
    }
}
