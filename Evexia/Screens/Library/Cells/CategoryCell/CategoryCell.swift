//
//  CategoryCell.swift
//  Evexia Staging
//
//  Created by admin on 10.10.2021.
//

import UIKit

class CategoryCell: UICollectionViewCell, CellIdentifiable {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.shadowView.backgroundColor = .clear
        self.shadowView.layer.cornerRadius = 12.0
        self.shadowView.layer.shadowRadius = 4.0
        self.shadowView.layer.shadowColor = UIColor.gray400.cgColor
        self.shadowView.layer.shadowOpacity = 0.0
        self.shadowView.layer.shadowOffset = .zero
    }

    override var isSelected: Bool {
        didSet {
            self.selected(isSelected)
        }
    }
    
    func configCell(with model: Focus) {
        self.categoryLabel.text = model.rawValue.capitalized.localized()
    }
    
    private func selected(_ selected: Bool) {
        if selected {
            self.categoryLabel.textColor = .orange
            self.categoryLabel.font = UIFont(name: "NunitoSans-Bold", size: 18.0)!
            self.shadowView.layer.shadowOpacity = 0.5
            self.shadowView.backgroundColor = .white
        } else {
            self.categoryLabel.textColor = .gray900
            self.categoryLabel.font = UIFont(name: "NunitoSans-Semibold", size: 18.0)!
            self.shadowView.layer.shadowOpacity = 0.0
            self.shadowView.backgroundColor = .clear

        }
    }
}
