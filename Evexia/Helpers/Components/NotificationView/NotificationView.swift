//
//  NotificationView.swift
//  Evexia
//
//  Created by  Artem Klimov on 02.07.2021.
//

import UIKit
import Combine
import Atributika

class NotificationView: UIView {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var resendButton: RequestButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet private weak var gradientView: GradientView!
    @IBOutlet private var view: UIView!
    @IBOutlet private weak var contentView: UIView!
    
    @IBAction func actionButtonDidTap(_ sender: RequestButton) {
        self.actionButtonDidTap.send(())
    }
    
    @IBAction func backButtonDidTap(_ sender: UIButton) {
        self.backButtonDidTap.send(())
    }
    
    var actionButtonDidTap = PassthroughSubject<Void, Never>()
    var backButtonDidTap = PassthroughSubject<Void, Never>()
    
    private var cornerRadius: CGFloat = 26.0
    
    private var paragraphStyle: NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.0
        paragraphStyle.alignment = .center
        return paragraphStyle
    }
    
    var descriptionStyle: Style {
        return Style()
            .foregroundColor(.blue84, .normal)
            .font(UIFont(name: "Outfit-Light", size: 16.0)!)
            .custom(self.paragraphStyle, forAttributedKey: NSAttributedString.Key.paragraphStyle)
    }
    
    var titleStyle: Style {
        return Style()
            .foregroundColor(.blue84, .normal)
            .font(UIFont(name: "Outfit-SemiBold", size: 20.0)!)
            .custom(self.paragraphStyle, forAttributedKey: NSAttributedString.Key.paragraphStyle)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    
    private func nibSetup() {
        backgroundColor = .clear
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        self.setupGradientView()
        self.setupButtons()
        self.setupContentView()
        addSubview(view)
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return nibView
    }
    
    private func setupContentView() {
        self.contentView.layer.cornerRadius = self.cornerRadius
        self.contentView.dropShadow(radius: self.cornerRadius, xOffset: 0.0, yOffset: 2.0, shadowOpacity: 0.5, shadowColor: UIColor(hex: "CBD5E0")!)
    }
    
    private func setupButtons() {
        self.backButton.layer.cornerRadius = self.cornerRadius
        self.backButton.layer.borderWidth = 2.0
        self.backButton.layer.borderColor = UIColor.blue84.cgColor
        self.resendButton.layer.cornerRadius = self.cornerRadius
    }
    
    private func setupGradientView() {
        self.gradientView.startColor = .grayF0
        self.gradientView.endColor = .grayF0
    }
}
