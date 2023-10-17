//
//  TakeBreakAlertView.swift
//  Evexia Staging
//
//  Created by Oleg Pogosian on 20.01.2022.
//

import UIKit
import Combine

class TakeBreakAlertView: UIView {
    
    // MARK: - IBOutlets
    @IBOutlet weak var alertTitleLabel: UILabel!
    @IBOutlet weak var alertDesriptionLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var takeButton: UIButton!
    @IBOutlet weak var shadowView: UIView!
    
    // MARK: - Properties
    var takeButtonDidTap = PassthroughSubject<Void, Never>()
    var cancelButtonDidTap = PassthroughSubject<Void, Never>()
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    // MARK: - UI
    private func setupUI() {
        cancelButton.layer.cornerRadius = 20
        cancelButton.layer.borderColor = UIColor.gray500.cgColor
        cancelButton.layer.borderWidth = 1
        
        takeButton.layer.cornerRadius = 20
        shadowView.layer.cornerRadius = 24
    }
    
    func configurate(breaksCount: Int) {
        let сountAttempt = breaksCount == 2 ? "first" : "second"
        alertDesriptionLabel.text = "You have \(breaksCount) “take a break” options to use per month. Click here to use your \(сountAttempt) break."
    }
    
    // MARK: - IBActions
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.cancelButtonDidTap.send()
    }
    
    @IBAction func takeButtonAction(_ sender: Any) {
        self.takeButtonDidTap.send()
    }
}
