//
//  WeightStatisticCell.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 01.09.2021.
//

import UIKit

class WeightStatisticCell: UITableViewCell, CellIdentifiable {

    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func configCell(with model: Stats) {
        self.weightLabel.text = model.score.getUnitWithSybmols(unitType: .mass)
        self.dateLabel.text = model.date
    }
}
