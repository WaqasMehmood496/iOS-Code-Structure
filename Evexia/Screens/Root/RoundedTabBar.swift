//
//  RoundedTabBar.swift
//  Evexia
//
//  Created by admin on 16.09.2021.
//

import Foundation
import UIKit

class CardTabBar: BaseCardTabBar {
    
    override var preferredTabBarHeight: CGFloat {
        (UIScreen.main.bounds.width - 32) / 5.0
    }
    
    override var preferredBottomBackground: UIColor {
        .clear
    }
    
    lazy var containerView: UIView = UIView()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        
        return stackView
    }()
    
    lazy var indicatorView: PTIndicatorView = {
        let view = PTIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.constraint(width: 4)
        view.backgroundColor = .gray900
        view.makeWidthEqualHeight()
        
        return view
    }()
    
    private var indicatorViewXConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit {
        stackView.arrangedSubviews.forEach {
            if let button = $0 as? UIControl {
                button.removeTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
            }
        }
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        
        subviewsPreparedAL {
            SubviewsBuilder.buildBlock(containerView)
        }
        
        containerView.subviewsPreparedAL {
            return SubviewsBuilder.buildBlock(stackView)
        }
        
        containerView.subviewsPreparedAL {
            return SubviewsBuilder.buildBlock(indicatorView)
        }
        
        containerView.pinToSuperView(top: 0, left: 16, bottom: 4, right: -16)
        stackView.pinToSuperView(top: 0, left: 0, bottom: nil, right: 0)
        stackView.centerInSuperView()
        
        indicatorView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: -12).isActive = true
        
        updateStyle()
    }
    
    func updateStyle() {
        containerView.backgroundColor = UIColor(named: "darkBlueNew")
    }

    override func set(items: [UITabBarItem]) {
        for button in (stackView.arrangedSubviews.compactMap { $0 as? BarButton }) {
            stackView.removeArrangedSubview(button)
            button.removeFromSuperview()
            button.removeTarget(self, action: nil, for: .touchUpInside)
        }
        
        for item in items {
            if let image = item.image {
                addButton(with: image)
            } else {
                addButton(with: UIImage())
            }
        }
        
        layoutIfNeeded()
    }
    
    override func select(at index: Int, animated: Bool, notifyDelegate: Bool) {
        if indicatorViewXConstraint != nil {
            indicatorViewXConstraint.isActive = false
            indicatorViewXConstraint = nil
        }
        
        for (bIndex, button) in buttons().enumerated() {
            button.selectedColor = .orange
            button.isSelected = bIndex == index
            
            if bIndex == index {
                indicatorViewXConstraint = indicatorView.centerXAnchor.constraint(equalTo: button.centerXAnchor)
                indicatorViewXConstraint.isActive = true
            }
        }
        
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
        
        if notifyDelegate {
            self.delegate?.cardTabBar(self, didSelectItemAt: index)
        }
    }
    
    private func addButton(with image: UIImage) {
        let button = BarButton(image: image)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.selectedColor = .orange
        button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
        self.stackView.addArrangedSubview(button)
    }
    
    private func buttons() -> [BarButton] {
        return stackView.arrangedSubviews.compactMap { $0 as? BarButton }
    }
    
    @objc
    func buttonTapped(sender: BarButton) {
        if let index = stackView.arrangedSubviews.firstIndex(of: sender) {
            select(at: index, animated: true, notifyDelegate: true)
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let position = touches.first?.location(in: self.containerView) else {
            super.touchesEnded(touches, with: event)
            return
        }
        
        let buttons = self.stackView.arrangedSubviews.compactMap { $0 as? BarButton }
        
        let frames = buttons.map { stackView.convert($0.frame, to: self.containerView) }
        let distances = frames.map { CGPoint(x: $0.midX, y: $0.midY).distance(to: position) }
        
        let buttonsDistances = zip(buttons, distances)
        
        if let closestButton = buttonsDistances.min(by: { $0.1 < $1.1 }) {

            buttonTapped(sender: closestButton.0)
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = containerView.bounds.height / 4
    }
}

extension CardTabBar {
    open class PTIndicatorView: UIView {
        override open func layoutSubviews() {
            super.layoutSubviews()
            self.backgroundColor = .orange
            self.layer.cornerRadius = self.bounds.height / 2
        }
    }

    public class BarButton: UIButton {
        
        var selectedColor: UIColor = .orange {
            didSet {
                reloadApperance()
            }
        }
        
        var unselectedColor: UIColor = .white {
            didSet {
                reloadApperance()
            }
        }
        
        init(forItem item: UITabBarItem) {
            super.init(frame: .zero)
            setImage(item.image, for: .normal)
        }
        
        init(image: UIImage) {
            super.init(frame: .zero)
            setImage(image, for: .normal)
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override public var isSelected: Bool {
            didSet {
                reloadApperance()
            }
        }
        
        func reloadApperance() {
            self.tintColor = isSelected ? selectedColor : unselectedColor
        }
    }

}

protocol CardTabBarDelegate: AnyObject {
    func cardTabBar(_ sender: BaseCardTabBar, didSelectItemAt index: Int)
}

class BaseCardTabBar: UIView {
    
    var preferredTabBarHeight: CGFloat {
        68
    }
    
    var preferredBottomBackground: UIColor {
        .clear
    }
    
    weak var delegate: CardTabBarDelegate?
    
    func select(at index: Int, animated: Bool, notifyDelegate: Bool) {
        
    }
    
    func set(items: [UITabBarItem]) {
        
    }
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return hypot(self.x - point.x, self.y - point.y)
    }
}

public struct SubviewsBuilder {
    public static func buildBlock(_ content: UIView...) -> [UIView] {
        return content
    }
}

/**
 Creating a chainable stackview to make life easiere
 */

extension UIStackView {
    @discardableResult
    func alignment(_ alignment: Alignment) -> UIStackView {
        self.alignment = alignment
        return self
    }

    @discardableResult
    func distribution(_ distribution: Distribution) -> UIStackView {
        self.distribution = distribution
        return self
    }

    @discardableResult
    func spacing(_ spacing: CGFloat) -> UIStackView {
        self.spacing = spacing
        return self
    }

    @discardableResult
    func axis(_ axis: NSLayoutConstraint.Axis) -> UIStackView {
        self.axis = axis
        return self
    }

    @discardableResult
    func addingArrangedSubviews(_ arrangedSubviews: [UIView]) -> UIStackView {
        arrangedSubviews.forEach {
            self.addArrangedSubview($0)
        }

        return self
    }

    @discardableResult
    func preparedForAutolayout() -> UIStackView {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }

    @discardableResult
    func addingArrangedSubviews(content: () -> [UIView]) -> UIStackView {
        for sv in content() {
            addArrangedSubview(sv)
            sv.translatesAutoresizingMaskIntoConstraints = false
        }
        return self
    }
}

extension UIView {
    func subviewsPreparedAL(content: () -> [UIView]) {
        for view in content() {
            addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}

extension UIView {
    func pinToSafeArea(top: CGFloat? = 0, left: CGFloat? = 0, bottom: CGFloat? = 0, right: CGFloat? = 0) {
        guard let superview = self.superview else { return }
        
        prepareForAutoLayout()
        
        let guide: UILayoutGuide = superview.safeAreaLayoutGuide

        if let top = top {
            self.topAnchor.constraint(equalTo: guide.topAnchor, constant: top).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: bottom).isActive = true
        }
        
        if let left = left {
            self.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: left).isActive = true
        }
        
        if let right = right {
            self.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: right).isActive = true
        }
    }
    
    func pinToSuperView(top: CGFloat? = 0, left: CGFloat? = 0, bottom: CGFloat? = 0, right: CGFloat? = 0) {
        guard let superview = self.superview else { return }
        
        prepareForAutoLayout()
        
        if let top = top {
            self.topAnchor.constraint(equalTo: superview.topAnchor, constant: top).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: bottom).isActive = true
        }
        
        if let left = left {
            self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: left).isActive = true
        }
        
        if let right = right {
            self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: right).isActive = true
        }
    }
    
    func centerInSuperView() {
        guard let superview = self.superview else { return }
        
        prepareForAutoLayout()
        
        self.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
    }
    
    func constraint(width: CGFloat) {
        prepareForAutoLayout()
        self.widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func constraint(height: CGFloat) {
        prepareForAutoLayout()
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func makeWidthEqualHeight() {
        prepareForAutoLayout()
        self.widthAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    func prepareForAutoLayout() {
        translatesAutoresizingMaskIntoConstraints = false
    }
}
