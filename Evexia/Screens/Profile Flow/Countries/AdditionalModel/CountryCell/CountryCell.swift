//
//  CountryCell.swift
//  Evexia Staging
//
//  Created by  Artem Klimov on 09.08.2021.
//

import UIKit

class CountryCell: UITableViewCell, CellIdentifiable {

    // IBOutlets
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    
    func configCell(with model: CountryCellModel) {
        self.countryLabel.text = model.country
        self.countryLabel.font = model.country == UserDefaults.userModel?.country ? UIFont(name: "NunitoSans-Bold", size: 16.0)! : UIFont(name: "NunitoSans-Regular", size: 16.0)!
        self.countryLabel.textColor = model.country == UserDefaults.userModel?.country ? .gray900 : .gray700
        self.selectButton.alpha = model.country == UserDefaults.userModel?.country ? 1.0 : 0.0
    }
}
