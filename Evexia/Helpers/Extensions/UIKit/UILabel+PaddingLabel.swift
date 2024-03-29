//
//  UILabel+PaddingLabel.swift
//  Evexia
//
//  Created by admin on 29.09.2021.
//

import UIKit

class PaddingLabel: UILabel {
    var textEdgeInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textEdgeInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textEdgeInsets.top, left: -textEdgeInsets.left, bottom: -textEdgeInsets.bottom, right: -textEdgeInsets.right)
        return textRect.inset(by: invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textEdgeInsets))
    }
    
    var paddingLeft: CGFloat {
        get { return textEdgeInsets.left }
        set { textEdgeInsets.left = newValue }
    }
    
    var paddingRight: CGFloat {
        get { return textEdgeInsets.right }
        set { textEdgeInsets.right = newValue }
    }
    
    var paddingTop: CGFloat {
        get { return textEdgeInsets.top }
        set { textEdgeInsets.top = newValue }
    }
    
    var paddingBottom: CGFloat {
        get { return textEdgeInsets.bottom }
        set { textEdgeInsets.bottom = newValue }
    }
}
