//
//  AlertAction.swift
//  Evexia
//
//  Created by  Artem Klimov on 07.07.2021.
//

import Foundation
import UIKit

enum AlertActionStyle {
    case normal
    case highlight
    case cancel
}

class AlertAction: UIButton {
    
    // MARK: - Properties
    internal var action: (() -> Void)?
    
    var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = self.borderColor.cgColor
        }
    }
    
    var borderWidth: CGFloat = 1.0 {
        didSet {
            layer.borderWidth = self.borderWidth
        }
    }
    
    var cornerRadius: CGFloat = 16 {
        didSet {
            layer.cornerRadius = self.cornerRadius
        }
    }
        
    public var title: String? {
        willSet {
            setTitle(newValue, for: .normal)
        }
    }
    
    public var titleColor: UIColor? {
        willSet {
            setTitleColor(newValue, for: .normal)
        }
    }
    
    public var titleFont: UIFont? {
        willSet {
            self.titleLabel?.font = newValue
        }
    }
    
    public var actionBackgroundColor: UIColor? {
        willSet {
            backgroundColor = newValue
        }
    }
    
    // MARK: - Initializers
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.cornerRadius = self.cornerRadius
    }
    
    public init(title: String, titleColor: UIColor) {
        super.init(frame: .zero)
        
        self.setTitle(title.uppercased(), for: .normal)
        self.setTitleColor(titleColor, for: .normal)
    }
    
    public convenience init(title: String, style: AlertActionStyle, action: (() -> Void)? = nil) {
        self.init(type: .system)
        
        self.action = action
        self.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        
        switch style {
        case .normal:
            self.setTitle(title: title, forStyle: .normal)
        case .cancel:
            self.setTitle(title: title, forStyle: .cancel)
        case .highlight:
            self.setTitle(title: title, forStyle: .highlight)
        }
    }
    
    // MARK: - Methods
    func setTitle(title: String, forStyle: AlertActionStyle) {
        self.setTitle(title, for: .normal)
        clipsToBounds = true
        
        switch forStyle {
        case .normal:
            setTitleColor(.white, for: .normal)
            self.actionBackgroundColor = .blue
            self.titleFont = UIFont(name: "Outfit-Semibold", size: 20.0)
        case .cancel:
            setTitleColor(.gray900, for: .normal)
            self.borderWidth = 1.0
            self.borderColor = .gray500
            self.titleFont = UIFont(name: "Outfit-Semibold", size: 20.0)
        case .highlight:
            setTitleColor(.white, for: .normal)
            self.actionBackgroundColor = .error
            self.titleFont = UIFont(name: "Outfit-Semibold", size: 20.0)
        }
    }
    
    @objc
    func actionTapped(sender: AlertAction) {
        self.action?()
    }
}
