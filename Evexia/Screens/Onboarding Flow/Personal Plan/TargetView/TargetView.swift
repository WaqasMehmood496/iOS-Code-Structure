//
//  TargetView.swift
//  Evexia Staging
//
//  Created by  Artem Klimov on 15.07.2021.
//

import UIKit
import Combine

class TargetView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var dashPatternView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    
    let dashBorder = CAShapeLayer()
    var focus: Focus?
    var isEmptyTarget = CurrentValueSubject<Bool, Never>(true)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.nibSetup()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.view.layer.cornerRadius = 6.0
        self.dashPatternView.layer.cornerRadius = 6.0
       
        dashBorder.strokeColor = UIColor.gray500.cgColor
        dashBorder.lineWidth = 2
        dashBorder.frame = dashPatternView.bounds
        dashBorder.lineDashPattern = [0.94, 2.05]
        dashBorder.lineJoin = CAShapeLayerLineJoin.bevel
        dashBorder.frame = view.bounds
        dashBorder.fillColor = nil
        dashBorder.path = UIBezierPath(roundedRect: dashPatternView.bounds, cornerRadius: 6.0).cgPath
        self.dashPatternView.layer.addSublayer(dashBorder)
        self.view.layer.masksToBounds = true

    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return nibView
    }
    
    private func nibSetup() {
        backgroundColor = .clear
        self.view = loadViewFromNib()
        self.view.frame = bounds
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.translatesAutoresizingMaskIntoConstraints = true
        addSubview(view)
    }
}

extension UIView {
    func rotate(radians: CGFloat) {
        self.transform = CGAffineTransform(rotationAngle: radians)
    }
}
