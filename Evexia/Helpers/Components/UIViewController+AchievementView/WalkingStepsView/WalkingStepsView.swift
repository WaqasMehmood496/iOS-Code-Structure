//
//  WalkingStepsView.swift
//  Evexia
//
//  Created by Oleksand Kovalov on 14.03.2022.
//

import UIKit
import SwiftEntryKit

// MARK: - WalkingStepsView
class WalkingStepsView: UIView {
    
    // MARK: - IBOutlets
    @IBOutlet var view: UIView!
    @IBOutlet private weak var cornerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet private weak var actionButton: UIButton!
    @IBOutlet private weak var planetImageView: UIImageView!

    // MARK: - Properties
    private let message: EKPopUpMessage
    
    // MARK: - Init
    init(with message: EKPopUpMessage) {
        self.message = message
        super.init(frame: UIScreen.main.bounds)
        nibSetup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Extension
private extension WalkingStepsView {
    func setupUI() {
        cornerView.layer.cornerRadius = 16
        actionButton.layer.cornerRadius = 16
    }
    
    func setupElements() {
        titleLabel.content = message.title
        subTitleLabel.content = message.description
        actionButton.buttonContent = message.button
        
        guard let themeImage = message.themeImage else { return }
        planetImageView.imageContent = themeImage.image
    }
    
    func nibSetup() {
        self.view = loadViewFromNib()
        self.view.frame = bounds
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.translatesAutoresizingMaskIntoConstraints = true
        setupElements()
        setupUI()
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return nibView
    }
}

// MARK: - Action
extension WalkingStepsView {
    @IBAction func tapToActionButton(_ sender: UIButton) {
        message.action()
    }
}
