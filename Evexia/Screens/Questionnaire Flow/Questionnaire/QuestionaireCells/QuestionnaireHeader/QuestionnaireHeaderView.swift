//
//  QuestionnaireHeaderView.swift
//  Evexia
//
//  Created by admin on 26.09.2021.
//

import UIKit
import Atributika

class QuestionnaireHeaderView: UITableViewHeaderFooterView, CellIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let backgroundView = UIView(frame: self.bounds)
        backgroundView.backgroundColor = .gray100
        self.backgroundView = backgroundView
    }
    
    func configHeader(with question: QuestionModel, index: Int) {
        let questionNumber = String(index + 1)
        self.titleLabel.attributedText = (questionNumber + ". " + question.question).styleAll(titleStyle).attributedString
        self.descriptionLabel.attributedText = question.description?.styleAll(descriptionStyle).attributedString
    }
    
    private var descriptionStyle: Style {
        return Style()
            .foregroundColor(.gray700, .normal)
            .font(UIFont(name: "NunitoSans-Regular", size: 16.0)!)
            .custom(self.descriptionParagraphStyle, forAttributedKey: NSAttributedString.Key.paragraphStyle)
    }
    
    private var titleStyle: Style {
        return Style()
            .foregroundColor(.gray900, .normal)
            .font(UIFont(name: "NunitoSans-Bold", size: 18.0)!)
            .custom(self.titleParagraphStyle, forAttributedKey: NSAttributedString.Key.paragraphStyle)
    }
    
    private var titleParagraphStyle: NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.33
        paragraphStyle.alignment = .left
        return paragraphStyle
    }
    
    private var descriptionParagraphStyle: NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5
        paragraphStyle.alignment = .left
        return paragraphStyle
    }
}
