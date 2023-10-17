//
//  CustomPopoverView.swift
//  Evexia
//
//  Created by Oleksand Kovalov on 27.02.2022.
//

import UIKit

// MARK: - CustomPopoverView
class CustomPopoverView: UIView {

    // MARK: - Life Cycle
    override func draw(_ rect: CGRect) {
        drawCornerView(with: rect)
    }
    
    // MARK: - Methods
    private func drawCornerView(with rect: CGRect) {
       let path = UIBezierPath()

        path.move(to: .init(x: bounds.maxX, y: bounds.midY - 9))
        path.addLine(to: .init(x: bounds.maxX + 9, y: bounds.midY))
        path.addLine(to: .init(x: bounds.maxX, y: bounds.midY + 9))
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.darkBlueNew.cgColor

        layer.addSublayer(shapeLayer)
    }
}
