//
//  AdviceHint.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 19.08.2021.
//

import UIKit
import Atributika
import Combine

class AdviseHint: UIView {

    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet private weak var view: UIView!
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var smallGradientView: GradientView!
    @IBOutlet private weak var imageGradientView: GradientView!
    @IBOutlet private weak var closeHintButton: UIButton!
    @IBOutlet weak var widthContentViewConstant: NSLayoutConstraint!
    
    internal var closeViewPublisher = PassthroughSubject<Void, Never>()
    
    var titleStyle: Style {
        return Style()
            .foregroundColor(.gray100, .normal)
            .font(UIFont(name: "NunitoSans-Bold", size: 16.0)!)
            .custom(self.paragraphStyle, forAttributedKey: NSAttributedString.Key.paragraphStyle)
    }
    
    private var paragraphStyle: NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.3
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
        self.backgroundView.layer.cornerRadius = self.cornerRadius
        self.imageGradientView.layer.cornerRadius = imageGradientView.frame.height / 2.0
        self.smallGradientView.layer.cornerRadius = smallGradientView.frame.height / 2.0
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
    
    @IBAction func closeHintButtonDidTap(_ sender: UIButton) {
        self.closeViewPublisher.send()
    }
    
    private func setupViews() {
        self.setupGradients()
    }
    
    private func setupGradients() {
        self.smallGradientView.startColor = UIColor(hex: "73AEE4") ?? .blueSurvey
        self.smallGradientView.endColor = UIColor(hex: "ECF3FE") ?? .blueSurvey
        
        self.imageGradientView.startColor = UIColor(hex: "73AEE4") ?? .blueSurvey
        self.imageGradientView.endColor = UIColor(hex: "ECF3FE") ?? .blueSurvey
        
        let shadowSize: CGFloat = 26.0
        let contactRect = CGRect(x: imageGradientView.bounds.midX - shadowSize / 2.0, y: imageGradientView.bounds.maxY - 10.0, width: shadowSize, height: shadowSize / 2.0)
        self.imageGradientView.layer.shadowPath = UIBezierPath(ovalIn: contactRect).cgPath
        self.imageGradientView.layer.shadowColor = UIColor(hex: "ECF3FE")?.cgColor ?? UIColor.blueSurvey.cgColor
        self.imageGradientView.layer.shadowRadius = 6.0
        self.imageGradientView.layer.shadowOpacity = 0.8
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return nibView
    }
}
