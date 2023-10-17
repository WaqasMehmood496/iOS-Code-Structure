//
//  CircleProgressButton.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 21.07.2021.
//

import UIKit

class CircleProgressButton: UIButton {
    
    // MARK: - Properties
    fileprivate var progressLayer = CAShapeLayer()
    fileprivate var trackLayer = CAShapeLayer()
    fileprivate var previousValue: Float = 0.0
    
    // MARK: - IBInspectable
    @IBInspectable var trackColor: UIColor = .gray300 {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }

    @IBInspectable var progressColor: UIColor = .orange {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        defaultInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        defaultInit()
    }
    
    fileprivate func defaultInit() {
        layer.cornerRadius = frame.size.height / 2
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(
                x: frame.size.width / 2.0,
                y: frame.size.height / 2.0
            ),
            radius: (frame.size.width + 30) / 2,
            startAngle: CGFloat(.pi / -2.0),
            endAngle: CGFloat(1.5 * .pi),
            clockwise: true
        )
        trackLayer.path = circlePath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = 5.0
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)
        
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = 5.0
        progressLayer.strokeEnd = 0.0
        layer.addSublayer(progressLayer)
    }
    
    // MARK: - Public methods
    func setProgress(to toValue: Float, duration: TimeInterval = 0.3) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = previousValue
        animation.toValue = toValue
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        previousValue = toValue
        progressLayer.strokeEnd = CGFloat(toValue)
        progressLayer.add(animation, forKey: "setProgress")
    }
}
