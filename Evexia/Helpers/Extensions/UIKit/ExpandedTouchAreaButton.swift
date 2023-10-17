//
//  ExpandedTouchAreaButton.swift
//  Evexia
//
//  Created by Oleksand Kovalov on 04.03.2022.
//

import UIKit

@IBDesignable
class ExpandedTouchAreaButton: UIButton {

    @IBInspectable var margin: CGFloat = 20.0
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
       
        let area = self.bounds.insetBy(dx: -margin, dy: -margin)
        return area.contains(point)
    }

}
