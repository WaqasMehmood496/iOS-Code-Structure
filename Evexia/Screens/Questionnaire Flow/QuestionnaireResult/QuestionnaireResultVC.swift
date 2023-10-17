//
//  QuestionnaireResultVC.swift
//  Evexia
//
//  Created by admin on 28.09.2021.
//

import Foundation
import UIKit
import Combine
import Atributika

class QuestionnaireResultVC: BaseViewController, StoryboardIdentifiable {
    
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var scoreTitleLable: UILabel!
    @IBOutlet private weak var scoreLabel: UILabel!
    @IBOutlet private weak var resultTextView: UITextView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var gradiendView: GradientView!
    
    @IBOutlet private weak var supportButton: RequestButton!
    @IBOutlet private weak var libraryButton: RequestButton!
    
    internal var viewModel: QuestionnaireResultVM!
    
    private var resultStyle: Style {
        return Style()
            .foregroundColor(.gray900, .normal)
            .font(UIFont(name: "NunitoSans-Bold", size: 18.0)!)
            .custom(self.titleParagraphStyle, forAttributedKey: NSAttributedString.Key.paragraphStyle)
    }
    
    private var titleParagraphStyle: NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3.0
        paragraphStyle.alignment = .left
        return paragraphStyle
    }
    private var score = 0
    
    @IBAction private func closeButtonDidTap(_ sender: UIButton) {
        self.viewModel.closeView()
    }
    
    @IBAction private func supportButtonDidTap(_ sender: UIButton) {
        if viewModel.result == .hight || viewModel.result == .veryHight {
            self.viewModel.navigateToDiary()
        } else {
            self.viewModel.navigateToCustomerSupport()
        }
        
    }
    
    @IBAction private func libraryButtonDidTap(_ sender: Any) {
        self.viewModel.navigateToLibrary()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupButtons()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    private func setupUI() {
        score = Int(viewModel.result.value) ?? 0
        self.setupLabels()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        (self.tabBarController as? TabBarController)?.setTabBarHidden(true, animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.setupViews()
        self.setupGradients()
    }
    
    private func setupLabels() {
        self.scoreTitleLable.text = "Wellbeing score:".localized()
        self.scoreLabel.text = self.viewModel.result.value
        self.resultTextView.attributedText = self.viewModel.result.description.styleAll(self.resultStyle).attributedString
        self.resultTextView.textContainerInset = .zero
        self.resultTextView.showsVerticalScrollIndicator = false
        
    }
    
    private func setupButtons() {
        if viewModel.result == .hight || viewModel.result == .veryHight {
            self.supportButton.setTitle("Go to My Diary", for: .normal)
        } else {
            self.supportButton.setTitle("Advice and Support", for: .normal)
        }
        self.libraryButton.layer.borderWidth = 1.0
        self.libraryButton.layer.borderColor = UIColor.gray500.cgColor
    }
    
    private func setupViews() {
        self.contentView.layer.cornerRadius = 16.0
        self.contentView.layer.shadowOffset = .zero
        self.contentView.layer.shadowColor = UIColor.gray400.cgColor
        self.contentView.layer.shadowRadius = 20.0
        self.contentView.layer.shadowOpacity = 0.5
        
        self.gradiendView.layer.cornerRadius = 16.0
        self.gradiendView.layer.cornerRadius = gradiendView.frame.height / 2.0
        self.gradiendView.layer.masksToBounds = true
    }
    
    private func setupGradients() {
        
        self.gradiendView.startColor = UIColor(hex: "FFCC00") ?? .feel
        self.gradiendView.endColor = UIColor(hex: "FFE066") ?? .feel
        
        let shadowSize: CGFloat = 42.0
        let contactRect = CGRect(x: gradiendView.bounds.midX - shadowSize / 2.0, y: gradiendView.bounds.maxY - 14.0, width: shadowSize, height: shadowSize / 2.0)
        self.gradiendView.layer.shadowPath = UIBezierPath(ovalIn: contactRect).cgPath
        self.gradiendView.layer.shadowColor = UIColor(hex: "FFE066")?.cgColor ?? UIColor.feel.cgColor
        self.gradiendView.layer.shadowRadius = 6.0
        self.gradiendView.layer.shadowOpacity = 0.8
    }
}
