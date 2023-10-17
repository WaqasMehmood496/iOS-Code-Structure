//
//  TutorialHintView.swift
//  Evexia
//
//  Created by admin on 15.09.2021.
//

import Foundation
import UIKit
import Atributika

class TutorialHintView: UIView {
    
    // MARK: - IBOutlets
    @IBOutlet var view: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeHintButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var descriptionStyle: Style {
        return Style()
            .foregroundColor(.gray400, .normal)
            .font(UIFont(name: "NunitoSans-Regular", size: 14.0)!)
            .custom(self.paragraphStyle, forAttributedKey: NSAttributedString.Key.paragraphStyle)
    }
    
    var titleStyle: Style {
        return Style()
            .foregroundColor(.gray100, .normal)
            .font(UIFont(name: "NunitoSans-Bold", size: 16.0)!)
            .custom(self.paragraphStyle, forAttributedKey: NSAttributedString.Key.paragraphStyle)
    }
    
    private var paragraphStyle: NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        // paragraphStyle.lineHeightMultiple = 1.3
        paragraphStyle.alignment = .left
        return paragraphStyle
    }
    
    private var cornerRadius: CGFloat = 16.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.nibSetup()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.cornerRadius = self.cornerRadius
        self.layer.masksToBounds = true
    }
    
    private func nibSetup() {
        backgroundColor = .clear
        self.view = loadViewFromNib()
        self.view.frame = bounds
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.translatesAutoresizingMaskIntoConstraints = true
        self.setupViews()
        addSubview(view)
    }
    @IBAction func closeButtonDidTap(_ sender: UIButton) {
        if UserDefaults.currentTutorial == .favorite {
            UserDefaults.needShowLibraryTutorial = false
            if UserDefaults.needShowDiaryTutorial {
                UserDefaults.currentTutorial = .start
            } else {
                UserDefaults.currentTutorial = nil
            }
        } else {
            UserDefaults.needShowDiaryTutorial = false
            UserDefaults.currentTutorial = nil
        }
    }
    
    private func setupViews() {
        closeHintButton.isUserInteractionEnabled = true
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return nibView
    }
}
