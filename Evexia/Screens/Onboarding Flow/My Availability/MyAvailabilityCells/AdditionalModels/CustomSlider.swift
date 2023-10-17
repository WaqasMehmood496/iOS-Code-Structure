//
//  CustomSlider.swift
//  Evexia
//
//  Created by  Artem Klimov on 20.07.2021.
//

import UIKit
import Combine

class TimeSlider: UISlider {
    
    var currentValue = PassthroughSubject<Float, Never>()
    var outerThumbSize: CGFloat = 24.0
    var innerThumbSize: CGFloat = 8.0
    
    private lazy var thumbView: UIView = {
        let thumb = UIView()
        thumb.backgroundColor = .orange
        return thumb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let thumb = thumbImage()
        setThumbImage(thumb, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let thumb = thumbImage()
        setThumbImage(thumb, for: .normal)
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.trackRect(forBounds: bounds)
        rect.size.height = 4
        rect.origin.y -= 4 / 2
        return rect
      }
    
    private func thumbImage() -> UIImage {
        self.thumbView.frame = CGRect(x: 0, y: outerThumbSize / 2, width: outerThumbSize, height: outerThumbSize)
        self.thumbView.layer.cornerRadius = outerThumbSize / 2
        self.thumbView.backgroundColor = .orange
        
        let layer = CALayer()
        layer.frame = CGRect(x: outerThumbSize / 2 - innerThumbSize / 2, y: outerThumbSize / 2 - innerThumbSize / 2, width: innerThumbSize, height: innerThumbSize)
        layer.backgroundColor = UIColor.white.cgColor
        layer.cornerRadius = 4.0
        
        self.thumbView.layer.addSublayer(layer)
        let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
        
        return renderer.image { rendererContext in
            self.thumbView.layer.render(in: rendererContext.cgContext)
        }
    }
    
    // - increase touch area for slider thumb
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var bounds: CGRect = self.bounds
        bounds = bounds.insetBy(dx: -10, dy: -10)
        return bounds.contains(point)
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let point: CGPoint = touch.location(in: self)
        
        let positionOfSlider: CGPoint = self.bounds.origin
        let widthOfSlider: CGFloat = self.bounds.width
        let newValue = ((point.x - positionOfSlider.x) * CGFloat(self.maximumValue) / widthOfSlider)
        
        let step: Float = 15.0
        let currentValue = round(Float(newValue) / step) * step
        self.setValue(currentValue, animated: false)
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        self.currentValue.send(self.value)
    }
 
}
