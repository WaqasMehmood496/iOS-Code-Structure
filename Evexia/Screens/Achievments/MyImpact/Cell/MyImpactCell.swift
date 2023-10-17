//
//  MyImpactCell.swift
//  Evexia
//
//  Created by Oleksand Kovalov on 15.02.2022.
//

import UIKit

// MARK: - MyImpactCell
class MyImpactCell: UITableViewCell, CellIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var cornerView: UIView!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var carboneValueLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // MARK: - Methods
    func config(with model: CarboneModel) -> MyImpactCell {
        backgroundImageView.image = model.image
        titleLabel.text = model.title
        subTitleLabel.text = model.subTitle
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        carboneValueLabel.text = formatter.string(from: NSNumber(value: model.value))
        titleLabel.textColor = model.textColor
        carboneValueLabel.textColor = model.textColor
        subTitleLabel.textColor = model.textColor
        
        let carbonDioxide = NSAttributedString(string: "CO", attributes: [.font: UIFont(name: "NunitoSans-Bold", size: 20.0)!])
        let two = NSAttributedString(string: "2", attributes: [.font: UIFont(name: "NunitoSans-Bold", size: 8.0)!, .baselineOffset: -2])
        
        let text = NSMutableAttributedString()
        text.append(carbonDioxide)
        text.append(two)
        subTitleLabel.attributedText = text
        return self
    }
}

// MARK: - Private Extension
private extension MyImpactCell {
    func setupUI() {
        selectionStyle = .none
        shadowView.dropShadow(radius: 8, xOffset: 0, yOffset: 2, shadowOpacity: 1, shadowColor: UIColor.gray400.withAlphaComponent(0.5))
        cornerView.layer.masksToBounds = true
        cornerView.layer.cornerRadius = 8
    }
}
