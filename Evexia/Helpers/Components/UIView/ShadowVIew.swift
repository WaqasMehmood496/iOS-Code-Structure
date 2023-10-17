//
//  ShadowVIew.swift
//  Evexia
//
//  Created by admin on 06.10.2021.
//

import UIKit

class ShadowView: UIView {

    private let cornerView = UIView()

    override func draw(_ rect: CGRect) {
        self.layer.shadowColor = UIColor.gray400.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 8.0
        
        cornerView.backgroundColor = .white
        cornerView.frame = self.bounds
        cornerView.layer.cornerRadius = 8.0
        cornerView.layer.masksToBounds = true
        self.addSubview(cornerView)
        self.sendSubviewToBack(cornerView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cornerView.frame = self.bounds
    }
}
