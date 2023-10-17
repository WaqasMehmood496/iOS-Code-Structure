//
//  DashBoardTutorialView.swift
//  Evexia
//
//  Created by Oleksand Kovalov on 27.02.2022.
//

import UIKit
import SnapKit
import Combine

// MARK: - HintsOverlayItem
struct HintsOverlayItem {
    let title: String
    let subTitle: String
    let buttonImage: UIImage
    let navHeight: CGFloat
    let originRect: CGRect
    let rect: CGRect
}

// MARK: - DashBoardTutorialView
class DashBoardTutorialView: UIView {
    
    // MARK: - Properties
    let scrollTo = PassthroughSubject<Void, Never>()
    var hints: [HintsOverlayItem] = []
    private var currentIndex = 0
    private var topConsraint: Constraint?
    private var bottomConstraint: Constraint?
    
    private lazy var customPopoverView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkBlueNew
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NunitoSans-Bold", size: 16.0)!
        label.numberOfLines = 2
        label.textColor = .white
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NunitoSans-Regular", size: 14.0)!
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "close")!, for: .normal)
        button.addTarget(self, action: #selector(scrollToCell), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setLayout()
    }
    
    init(hints: [HintsOverlayItem]) {
        self.hints = hints
        super.init(frame: .zero)
        backgroundColor = .black.withAlphaComponent(0.6)
        setLayout()
    }
    
    func nextStep() {
        if hints.count > currentIndex + 1 {
            currentIndex += 1
            addNextMask()
            unpdateConstraintWhenNextStep()
        } else {
            removeFromSuperview()
        }
    }
}

// MARK: - Private Extension
private extension DashBoardTutorialView {
    func setLayout() {
        addSubview(customPopoverView)
        
        customPopoverView.addSubview(titleLabel)
        customPopoverView.addSubview(subTitleLabel)
        customPopoverView.addSubview(actionButton)
        
        customPopoverView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(hints[currentIndex].originRect.maxY + 20)
//            bottomConstraint =
//            make.bottom.equalTo(hints[currentIndex].originRect.minY - 40)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
//        topConsraint?.activate()
//        bottomConstraint?.deactivate()
        
        actionButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.top.right.equalToSuperview().inset(13)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(16)
            make.trailing.equalTo(actionButton.snp.leading).offset(-16)
            make.bottom.equalTo(subTitleLabel.snp.top).offset(-2)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview().inset(16)
        }
        
        addNextMask()
    }
    
    func addNextMask() {
        let path = CGMutablePath()
        
        path.addRoundedRect(in: hints[currentIndex].rect, cornerWidth: 8.0, cornerHeight: 8.0)
        
        path.addRect(CGRect(origin: .zero, size: UIScreen.main.bounds.size))
        
        let maskLayer = CAShapeLayer()
        
        maskLayer.backgroundColor = UIColor.black.cgColor
        
        maskLayer.path = path
        
        maskLayer.fillRule = .evenOdd
        
        layer.mask = maskLayer
        clipsToBounds = true
        
        titleLabel.text = hints[currentIndex].title
        subTitleLabel.text = hints[currentIndex].subTitle
        
        actionButton.setImage(hints[currentIndex].buttonImage, for: .normal)
    }
    
    func unpdateConstraintWhenNextStep() {
        if currentIndex == 1 {
            customPopoverView.snp.removeConstraints()
            
            customPopoverView.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(hints[currentIndex].originRect.origin.y - customPopoverView.bounds.height + 10)
                make.leading.trailing.equalToSuperview().inset(16)
            }
        } else {
            customPopoverView.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(hints[currentIndex].originRect.minY - customPopoverView.bounds.height - 40)
            }
        }
    }
    
    @objc
    func scrollToCell() {
        if currentIndex == 2 {
            removeFromSuperview()
        } else {
            scrollTo.send()
        }
       
    }
}
