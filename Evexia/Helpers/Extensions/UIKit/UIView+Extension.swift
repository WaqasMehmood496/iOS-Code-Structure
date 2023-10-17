//
//  UIViewP.swift
//  Evexia
//
//  Created by  Artem Klimov on 01.07.2021.
//


import UIKit

extension UIView {
    func dropShadow(radius: CGFloat = .zero, xOffset: CGFloat = .zero, yOffset: CGFloat = .zero, shadowOpacity: Float = 0.18, shadowColor: UIColor) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = radius
        self.layer.shadowOffset = CGSize(width: xOffset, height: yOffset)
    }
    
    func fadeTransition(_ duration: CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
    
    func animation(_ duration: TimeInterval) {
        UIView.animate(withDuration: duration, animations: {
            self.superview?.layoutIfNeeded()
        })
    }
    
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
    func addBlur(with style: UIBlurEffect.Style = .dark, color: UIColor = .clear, isInsert: Bool = false, blurRadius: CGFloat = 2, colorTintAlpha: CGFloat = 0) {
        let blurEffectView = BlurView.addBlurView(with: style, color: color, blurRadius: blurRadius, colorTintAlpha: colorTintAlpha, bounds: self.bounds)
        
        if subviews.first(where: { $0 is UIVisualEffectView }) != nil {
            Log.debug("Already was add VisualEffectView")
        } else {
            isInsert ? insertSubview(blurEffectView, at: 0) : addSubview(blurEffectView)
        }
    }
    
    func removeBlur() {
        if let view = self.subviews.first(where: { $0 is UIVisualEffectView }) {
            view.removeFromSuperview()
        }
    }
}

// GreyOpaqueBlur
extension UIView {
    
    func addGreyOpaqueBlur() {
        let view = GreyOpaqueBlur.createView(bounds: bounds)
        addSubview(view)
    }
    
    func removeGreyOpaqueBlur() {
        if let view = self.subviews.first(where: { $0 is GreyOpaqueBlur }) {
            view.removeFromSuperview()
        }
    }
}

class GreyOpaqueBlur: UIView {
    static func createView(bounds: CGRect) -> GreyOpaqueBlur {
        let view = GreyOpaqueBlur()
        view.frame = bounds
        view.backgroundColor = .black.withAlphaComponent(0.6)
        return view
    }
}

class BlurView  {
    static func addBlurView(with style: UIBlurEffect.Style = .prominent, color: UIColor = .clear, blurRadius: CGFloat = 2, colorTintAlpha: CGFloat = 0, bounds: CGRect) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurEffectView
    }
}
