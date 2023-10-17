//
//  StepsAchievmentCell.swift
//  Evexia
//
//  Created by Oleg Pogosian on 25.01.2022.
//

import UIKit

class StepsAchievmentCell: UICollectionViewCell, CellIdentifiable {

    // MARK: - IBOutlets
    @IBOutlet weak var stepsCountLabel: UILabel!
    @IBOutlet weak var achievmentImage: UIImageView!
    @IBOutlet weak var achievmentDescriptionLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    // MARK: - UI
    private func setupUI() {
        self.layer.cornerRadius = 8
    }
    
    func configure(model: ExploreAchivmentModel) {
        stepsCountLabel.text = "\(model.count ?? 0)"
        achievmentDescriptionLabel.text = model.descriptionText
    }
}
