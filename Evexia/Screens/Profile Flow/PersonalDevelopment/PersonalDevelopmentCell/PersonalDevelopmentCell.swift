//
//  PersonalDevelopmentTableViewCell.swift
//  Evexia Staging
//
//  Created by Oleg Pogosian on 07.12.2021.
//

import UIKit
import Combine

class PersonalDevelopmentCell: UITableViewCell, CellIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    // MARK: - UI
    func configure(with title: String, hideSeparator: Bool) {
        
        titleTextLabel.text = title
        separatorView.isHidden = hideSeparator
    }
    
}
