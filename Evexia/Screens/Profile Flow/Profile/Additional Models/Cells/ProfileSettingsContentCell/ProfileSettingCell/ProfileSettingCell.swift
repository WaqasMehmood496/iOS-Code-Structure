//
//  ProfileSettingCell.swift
//  
//
//  Created by  Artem Klimov on 18.08.2021.
//

import UIKit

class ProfileSettingCell: UITableViewCell, CellIdentifiable {

    @IBOutlet weak var settingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func configCell(with model: ProfileSettings) {
        self.settingLabel.text = model.title
    }
}
