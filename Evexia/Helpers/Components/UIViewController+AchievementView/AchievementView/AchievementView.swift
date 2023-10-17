//
//  AchievementView.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 05.10.2021.
//

import UIKit
import SwiftEntryKit

// MARK: AchievementView
class AchievementView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var setPlanLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    private let message: EKPopUpMessage

    init(with message: EKPopUpMessage) {
        self.message = message
        super.init(frame: UIScreen.main.bounds)
        nibSetup()
        widthConstraint.constant = UIScreen.main.bounds.width - 32
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     
    @IBAction func tapToActionButton(_ sender: UIButton) {
        message.action()
    }
}

// MARK: Extension AchievementView
extension AchievementView {
    
    private func setupUI() {
        contentView.layer.cornerRadius = 16
        actionButton.layer.cornerRadius = 16
        if message.title.text == "Congrats!" {
            setPlanLabel.isHidden = true
            lineView.isHidden = true
            self.layoutSubviews()
        }
    }
    
    private func setupElements() {
        titleLabel.content = message.title
        descriptionLabel.content = message.description
        actionButton.buttonContent = message.button
        
        guard let themeImage = message.themeImage else { return }
        imageView.imageContent = themeImage.image
    }
    
    private func nibSetup() {
        self.view = loadViewFromNib()
        self.view.frame = bounds
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.translatesAutoresizingMaskIntoConstraints = true
        setupElements()
        setupUI()
        addSubview(view)
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return nibView
    }
}
