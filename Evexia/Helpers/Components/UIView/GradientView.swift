//
//  GradientView.swift
//  Evexia
//
//  Created by  Artem Klimov on 01.07.2021.
//

import UIKit

final class GradientView: UIView {
    
    @IBInspectable var startColor: UIColor = .white
    @IBInspectable var endColor: UIColor = .black
        
    override func draw(_ rect: CGRect) {
        
        self.layer.cornerRadius = self.bounds.height / 2.0
        self.layer.masksToBounds = false
        let gradientView = UIView(frame: self.bounds)
    
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.frame = CGRect(x: CGFloat(0),
                                y: CGFloat(0),
                                width: frame.size.width,
                                height: frame.size.height)

        gradient.colors = [self.startColor.cgColor, self.endColor.cgColor]
        gradient.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradient.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradient.locations = [0, 1]
        gradient.zPosition = -1
        
        gradientView.layer.addSublayer(gradient)
        gradientView.layer.cornerRadius = self.frame.height / 2.0
        gradientView.layer.masksToBounds = true
        
        self.addSubview(gradientView)
        self.sendSubviewToBack(gradientView)
    }

}
