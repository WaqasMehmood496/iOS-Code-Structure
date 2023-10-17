//
//  AgreementsVC.swift
//  Evexia
//
//  Created by  Artem Klimov on 05.07.2021.
//

import UIKit
import Combine
import Atributika

class AgreementsVC: BaseViewController, StoryboardIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var gradientView: GradientView!
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var textView: AttributedLabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var effectiveDateLabel: UILabel!
    
    // MARK: - Properties
    internal var viewModel: AgreementsVMType!
    
    private var cancellables: [AnyCancellable] = []
    
    private var paragraphStyle: NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.0
        return paragraphStyle
    }
    
    private var plainAttributes: Style {
        return Style
            .foregroundColor(.gray700, .normal)
            .font(UIFont(name: "NunitoSans-Regular", size: 16.0)!)
            .custom(self.paragraphStyle, forAttributedKey: NSAttributedString.Key.paragraphStyle)
    }
    
    private var highlitedAttributes: Style {
        return Style("a")
            .foregroundColor(.orange, .normal)
            .foregroundColor(.orange, .highlighted)
            .font(UIFont(name: "NunitoSans-Semibold", size: 16.0)!)
            .custom(self.paragraphStyle, forAttributedKey: NSAttributedString.Key.paragraphStyle)
    }
    
    private var termsAttributes: Style {
        return Style("terms")
            .foregroundColor(.orange, .normal)
            .foregroundColor(.orange, .highlighted)
            .font(UIFont(name: "NunitoSans-Semibold", size: 16.0)!)
    }
    
    private var privacyAttributes: Style {
        return Style("privacy")
            .foregroundColor(.orange, .normal)
            .foregroundColor(.orange, .highlighted)
            .font(UIFont(name: "NunitoSans-Semibold", size: 16.0)!)
    }
    
    // MARK: - VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        (self.tabBarController as? TabBarController)?.setTabBarHidden(true, animated: false)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        (self.tabBarController as? TabBarController)?.setTabBarHidden(false, animated: false)

    }
}

// MARK: - Private Methods
private extension AgreementsVC {
    
    func setupUI() {
        self.scrollView.contentInsetAdjustmentBehavior = .never
        self.setupGradientView()
        self.setupContentView()
        self.setupLabels()
    }
    
    func setupLabels() {
        self.textView.numberOfLines = 0
        self.textView.onClick = { [weak self] _, detection in
            self?.click(detection: detection)
        }
        self.textView.attributedText = self.viewModel.type.text.style(tags: [self.termsAttributes, self.privacyAttributes]).styleAll(self.plainAttributes).styleLinks(highlitedAttributes)
        self.effectiveDateLabel.text = self.viewModel.type.dateText
        self.titleLabel.text = self.viewModel.type.title
        self.logoImageView.image = UIImage(named: self.viewModel.type.imageKey)
    }

    func setupContentView() {
        self.contentView.layer.cornerRadius = 16.0
        self.contentView.dropShadow(radius: 16.0, xOffset: 0.0, yOffset: 1.0, shadowOpacity: 0.2, shadowColor: .gray400)
    }
    
    func setupGradientView() {
        self.gradientView.startColor = UIColor(hex: "FFE066") ?? .feel
        self.gradientView.endColor = UIColor(hex: "FFCC00") ?? .feel
        
        let shadowSize: CGFloat = 36.0
        let contactRect = CGRect(x: gradientView.bounds.midX - shadowSize / 2.0, y: gradientView.bounds.maxY - 10.0, width: shadowSize, height: shadowSize / 2.0)
        self.gradientView.layer.shadowPath = UIBezierPath(ovalIn: contactRect).cgPath
        self.gradientView.layer.shadowColor = UIColor(hex: "FFE066")?.cgColor ?? UIColor.feel.cgColor
        self.gradientView.layer.shadowRadius = 6.0
        self.gradientView.layer.shadowOpacity = 0.8
    }
    
    func click(detection: Detection) {
        switch detection.type {
        case let .link(url):
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        case let .tag(tag):
            if tag.name == "terms" {
                self.viewModel.navigateToAgreements(type: .termsOfUse)
            } else {
                self.viewModel.navigateToAgreements(type: .privacyPolicy)
            }
        default:
            break
        }
    }
}
