//
//  UIView+Activity.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 12.09.2021.
//

import UIKit

extension UIView {
    func showActivityIndicator() {
        
        let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.frame = self.bounds
        activityIndicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
    }
    
    func removeActivityIndicator() {
        
        if let activityIndicator: UIView = self.subviews.first(where: { $0 is UIActivityIndicatorView }) {
            activityIndicator.removeFromSuperview()
        }
    }
}
