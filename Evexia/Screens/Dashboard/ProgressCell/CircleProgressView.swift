//
//  CircleProgressView.swift
//  Evexia
//
//  Created by admin on 11.09.2021.
//

import Foundation
import UIKit

@IBDesignable
class CircularProgressView: UIView {
    
    @IBInspectable var color: UIColor? = .gray {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var ringWidth: CGFloat = 12

    var weekProgress: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }
    
    var dayProgress: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }
    
    private var weekProgressLayer = CAShapeLayer()
    private var weekProgressMask = CAShapeLayer()
    
    private var dayProgressLayer = CAShapeLayer()
    private var dayProgressMask = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayers()

    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupLayers()
    }

    private func setupLayers() {
        self.weekProgressMask.lineWidth = ringWidth
        self.weekProgressMask.fillColor = nil

        self.weekProgressLayer.lineWidth = ringWidth
        self.weekProgressLayer.fillColor = nil
        
        self.dayProgressMask.lineWidth = ringWidth
        self.dayProgressMask.fillColor = nil
        
        self.dayProgressLayer.lineWidth = ringWidth
        self.dayProgressLayer.fillColor = nil
        
        layer.addSublayer(weekProgressMask)
        layer.addSublayer(weekProgressLayer)
        layer.addSublayer(dayProgressMask)
        layer.addSublayer(dayProgressLayer)

        layer.transform = CATransform3DMakeRotation(CGFloat(90 * Double.pi / 180), 0, 0, -1)
    }

    override func draw(_ rect: CGRect) {
        let dayProgressPath = UIBezierPath(ovalIn: rect.insetBy(dx: ringWidth / 2, dy: ringWidth / 2))
        let weekProgressPath = UIBezierPath(ovalIn: rect.insetBy(dx: (ringWidth / 2) + 12.0, dy: (ringWidth / 2) + 12.0 ))

        self.dayProgressMask.path = dayProgressPath.cgPath
        self.dayProgressLayer.path = dayProgressPath.cgPath
        
        self.dayProgressLayer.lineCap = .round
        self.dayProgressLayer.strokeStart = 0
        self.dayProgressLayer.strokeEnd = dayProgress
    
        self.dayProgressMask.strokeColor = UIColor.gray100.cgColor
        self.dayProgressLayer.strokeColor = UIColor.moveNew.cgColor
        
        self.weekProgressMask.path = weekProgressPath.cgPath
        self.weekProgressLayer.path = weekProgressPath.cgPath
        
        self.weekProgressLayer.lineCap = .round
        self.weekProgressLayer.strokeStart = 0
        self.weekProgressLayer.strokeEnd = weekProgress
     
        self.weekProgressMask.strokeColor = UIColor.gray200.cgColor
        self.weekProgressLayer.strokeColor = UIColor.eatNew.cgColor
    }
}
