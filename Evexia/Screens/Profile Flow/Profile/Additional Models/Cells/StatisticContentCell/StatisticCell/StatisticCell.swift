//
//  StatisticCell.swift
//  Evexia
//
//  Created by  Artem Klimov on 19.08.2021.
//

import UIKit

class StatisticCell: UICollectionViewCell, CellIdentifiable {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statImageView: UIImageView!
    @IBOutlet weak var indicatorLabel: UILabel!
    @IBOutlet weak var measureLabel: UILabel!
    @IBOutlet weak var disclosureImageView: UIImageView!
    @IBOutlet weak var backView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.contentView.layer.cornerRadius = 8.0
        self.contentView.layer.masksToBounds = true
    }
    
    func configCell(with model: ProfileStatistic) {
        let isWeight = model.type == .weight
        let measurement = model.value.changeMeasurementSystem(unitType: .mass)
        self.titleLabel.text = model.title
        let image = UIImage(named: model.focus.image_key)?.withRenderingMode(.alwaysTemplate)
        self.statImageView.image = image
        self.statImageView.tintColor = UIColor.white.withAlphaComponent(0.5)
        self.measureLabel.text = isWeight ? measurement.symbol : model.measure
        self.indicatorLabel.text = model.value.isEmpty ? "-" : model.value
        self.backView.backgroundColor = model.focus.tintColor
    }
    
}
