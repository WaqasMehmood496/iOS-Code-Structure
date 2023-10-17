//
//  PlayButton.swift
//  Evexia
//
//  Created by admin on 11.10.2021.
//

import UIKit
class PlayButton: UIButton {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.setupButton()
    }
    
    required init() {
        super.init(frame: .zero)
        self.setupButton()

    }
    
    private func setupButton() {
        self.setTitle("", for: .normal)
        let imageSize = CGSize(width: self.frame.height / 2.0, height: self.frame.height / 2.0)
        self.layer.cornerRadius = self.frame.height / 2.0
        self.layer.backgroundColor = UIColor.black.withAlphaComponent(0.5).cgColor
        self.tintColor = .white
        self.setImage(UIImage(named: "play"), for: .normal)
        
        let imageInset = (self.frame.height - imageSize.height) / 2
        self.imageEdgeInsets = UIEdgeInsets(top: imageInset, left: imageInset + 2.0, bottom: imageInset, right: imageInset)
    }
}
