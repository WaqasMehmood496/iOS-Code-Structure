//
//  RequestButton.swift
//  Evexia Staging
//
//  Created by  Artem Klimov on 25.06.2021.
//

import UIKit
import Combine

class RequestButton: UIButton {
    
    // - IBInspectable
    @IBInspectable var spinnerColor: UIColor = UIColor.white {
        didSet {
            self.indicator.color = spinnerColor
        }
    }
    
    @IBInspectable open var cornerRadius: CGFloat = 16.0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    
    @IBInspectable var color: UIColor = .blue
    
    public var isRequestAction = PassthroughSubject<Bool, Never>()
    
    private let indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    private var cancellables: [AnyCancellable] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.defaultInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.defaultInit()
    }
    
    private func defaultInit() {
        self.backgroundColor = color
        self.clipsToBounds = true
        self.indicator.color = .white
        self.setTitle(nil, for: .highlighted)
        
        self.isRequestAction
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isActive in
                switch isActive {
                case true:
                    self?.startSpinner()
                case false:
                    self?.stopSpinner()
                }
            }).store(in: &self.cancellables)
        
        self.publisher(for: \.isEnabled)
            .sink(receiveValue: { [weak self] isEnable in
                self?.backgroundColor = isEnable ? .blue : .blueInactive
            }).store(in: &self.cancellables)
    }
    
    private func startSpinner() {
        self.setTitleColor(.clear, for: .normal)
        self.showLoader(userInteraction: false)
    }
    
    private func stopSpinner() {
        self.hideLoader()
        self.setTitleColor(.white, for: .normal)
    }
    
    open func showLoader(userInteraction: Bool = true) {
        guard self.subviews.contains(indicator) == false else {
            return
        }
        self.isUserInteractionEnabled = userInteraction
        self.indicator.isUserInteractionEnabled = false
        self.indicator.center = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2)
        UIView.transition(with: self, duration: 0.2, options: .curveEaseOut, animations: {
            self.setTitleColor(.clear, for: .normal)
            self.titleLabel?.alpha = 0.0
            self.addSubview(self.indicator)
        }, completion: { _ in
            self.indicator.startAnimating()
        })
    }
    
    open func hideLoader() {
        guard self.subviews.contains(indicator) == true else {
            return
        }
        self.isUserInteractionEnabled = true
        self.indicator.stopAnimating()
        self.indicator.removeFromSuperview()
        UIView.transition(with: self, duration: 0.2, options: .curveEaseIn, animations: {
            self.titleLabel?.alpha = 1.0
            self.setTitleColor(.white, for: .normal)
        })
    }
}
