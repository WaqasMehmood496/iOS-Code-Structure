//
//  Checkbox.swift
//  Evexia
//
//  Created by  Artem Klimov on 30.06.2021.
//

import UIKit
import Combine

class Checkbox: UIControl {
    
    var isSelectedPublisher = PassthroughSubject<Bool, Never>()
    weak var check: CAShapeLayer?
    weak var selection: CAShapeLayer?
    @IBInspectable var cornerRadius: CGFloat = 12.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    @IBInspectable var borderColor: UIColor = .gray400 {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    @IBInspectable var borderWidth: CGFloat = 2.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var checkWidth: CGFloat = 2.0 {
        didSet {
            check?.path = checkPath(frame)
        }
    }
    @IBInspectable var checkColor: UIColor = .white {
        didSet {
            check?.strokeColor = checkColor.cgColor
        }
    }
    @IBInspectable var selectionBackgroundColor: UIColor = .orange {
        didSet {
            selection?.fillColor = selectionBackgroundColor.cgColor
        }
    }
    
    @IBInspectable var selectionBorderdColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    override func draw(_ rect: CGRect) {
        if check == nil || selection == nil {
            initLayers(rect)
        }
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        check?.path = checkPath(rect)
        selection?.path = selectionPath(isSelected: true, rect: rect)
    }
    
    @objc
    func selected() {
        isSelected = !isSelected
        self.isSelectedPublisher.send(isSelected)
        let animation = CABasicAnimation(keyPath: "transform")
        animation.duration = 0.15
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.isRemovedOnCompletion = false
        animation.fillMode = .both
        animation.fromValue = isSelected ? CATransform3DMakeScale(0.0, 0.0, 1.0) : CATransform3DMakeScale(1.4, 1.4, 1.0)
        animation.toValue = isSelected ? CATransform3DMakeScale(1.4, 1.4, 1.0) : CATransform3DMakeScale(0.0, 0.0, 1.0)
        selection?.add(animation, forKey: "path")
        self.borderColor = isSelected ? .clear : .gray400
    }
    
    private func checkPath(_ rect: CGRect) -> CGPath {
        let checkPath = UIBezierPath()
        let startPoint = CGPoint(x: rect.width * 0.0, y: rect.height * 0.5)
        checkPath.move(to: startPoint)
        let midPoint = CGPoint(x: rect.width * 0.3, y: rect.height * 0.85)
        checkPath.addLine(to: midPoint)
        let endPoint = CGPoint(x: rect.width * 0.95, y: rect.height * 0.05)
        checkPath.addLine(to: endPoint)
        checkPath.addLine(to: midPoint)
        checkPath.addLine(to: startPoint)
        checkPath.close()
        return checkPath.cgPath
    }
    
    func selectionPath(isSelected: Bool, rect: CGRect) -> CGPath {
        return UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: rect.width, height: rect.height)).cgPath
    }
    
    private func initLayers(_ rect: CGRect) {
        addTarget(self, action: #selector(selected), for: .touchUpInside)
        let selection = self.selection ?? selectionLayer(CGRect(x: 0, y: 0, width: rect.width, height: rect.height))
        let check = self.check ?? checkLayer(selection.frame)
        check.transform = CATransform3DMakeScale(0.4, 0.4, 1.0)
        selection.transform = isSelected ? CATransform3DMakeScale(1.4, 1.4, 1.0) : CATransform3DMakeScale(0.0, 0.0, 1.0)
        selection.addSublayer(check)
        layer.addSublayer(selection)
        self.check = check
        self.selection = selection
        layer.masksToBounds = true
    }
    
    private func selectionLayer(_ rect: CGRect) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.frame = rect
        layer.fillColor = selectionBackgroundColor.cgColor
        layer.masksToBounds = true
        layer.borderColor = UIColor.clear.cgColor
        return layer
    }
    
    private func checkLayer(_ rect: CGRect) -> CAShapeLayer {
        let check = CAShapeLayer()
        check.lineWidth = checkWidth
        check.frame = rect
        check.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        check.strokeColor = checkColor.cgColor
        return check
    }
}
