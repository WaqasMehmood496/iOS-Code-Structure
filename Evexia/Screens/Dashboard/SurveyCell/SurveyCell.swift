//
//  SurveyCell.swift
//  Evexia
//
//  Created by admin on 11.09.2021.
//

import UIKit
import Combine
import Atributika

class SurveyCell: UITableViewCell, CellIdentifiable {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var startSurveyButton: UIButton!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var backView: UIView!
    @IBOutlet private weak var surveyImageView: UIImageView!
    @IBOutlet private weak var imageGradientView: UIView!

    internal var startSurvey = PassthroughSubject<SurveyModel?, Never>()
    internal var skipSurvey = PassthroughSubject<SurveyModel?, Never>()
    internal var cancellables = Set<AnyCancellable>()
    
    private var descriptionStyle: Style {
        return Style()
            .foregroundColor(.gray400, .normal)
            .font(UIFont(name: "NunitoSans-Regular", size: 14.0)!)
            .custom(self.paragraphStyle, forAttributedKey: NSAttributedString.Key.paragraphStyle)
    }
    
    private var titleStyle: Style {
        return Style()
            .foregroundColor(.gray100, .normal)
            .font(UIFont(name: "NunitoSans-Bold", size: 16.0)!)
            .custom(self.paragraphStyle, forAttributedKey: NSAttributedString.Key.paragraphStyle)
    }
    
    private var paragraphStyle: NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.3
        paragraphStyle.alignment = .center
        return paragraphStyle
    }
    
    private var surveyModel: SurveyModel?
    
    private var cornerRadius: CGFloat = 16.0
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.backView.layer.cornerRadius = self.cornerRadius
        self.imageGradientView.layer.cornerRadius = self.imageGradientView.frame.height / 2.0
        self.startSurveyButton.layer.cornerRadius = self.cornerRadius
    }
    
    @IBAction func closeButtonDidTap(_ sender: UIButton) {
        self.skipSurvey.send(self.surveyModel)
    }
    
    @IBAction func startSurveyButtonDidTap(_ sender: Any) {
        self.startSurvey.send(self.surveyModel)
    }
    
    internal func configCell(for model: SurveyModel) {
        self.surveyModel = model
        self.surveyImageView.image = UIImage(named: model.type.image_key)
        self.titleLabel.attributedText = model.type.title.style(tags: self.titleStyle).attributedString
        self.descriptionLabel.attributedText = model.type.description.style(tags: self.descriptionStyle).attributedString
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()
    }
    
}
