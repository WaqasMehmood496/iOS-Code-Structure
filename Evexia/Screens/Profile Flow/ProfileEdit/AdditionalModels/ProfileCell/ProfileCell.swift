//
//  ProfileCell.swift
//  Evexia Staging
//
//  Created by  Artem Klimov on 28.07.2021.
//

import UIKit

class ProfileCell: UITableViewCell, CellIdentifiable {

    @IBOutlet weak var parameterLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func configCell(with model: ProfileCellModel) {
        self.parameterLabel.text = model.type.title

        switch model.type {
        case .weight:
            self.valueLabel.text = model.value
        case .height:
            self.valueLabel.text = model.value
        default:
            self.valueLabel.text = model.value
        }
    }
}
