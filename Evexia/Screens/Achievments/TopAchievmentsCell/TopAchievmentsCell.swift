//
//  TopAchievmentsCell.swift
//  Evexia
//
//  Created by Oleg Pogosian on 05.01.2022.
//

import UIKit

class TopAchievmentsCell: UICollectionViewCell, CellIdentifiable {

    // MARK: - IBOutlets
    @IBOutlet weak var stepsView: UIView!
    @IBOutlet weak var stepsCountLabel: UILabel!
    @IBOutlet weak var stepsDescriptionLabel: UILabel!
    @IBOutlet weak var daysInAppView: UIView!
    @IBOutlet weak var inAppCountLabel: UILabel!
    @IBOutlet weak var inAppDescriptionLabel: UILabel!
    @IBOutlet weak var prescribedView: UIView!
    @IBOutlet weak var prescribedCountLabel: UILabel!
    @IBOutlet weak var prescribedDescriptionLabel: UILabel!
    @IBOutlet weak var completedView: UIView!
    @IBOutlet weak var completedCountLabel: UILabel!
    @IBOutlet weak var completedDescriptionLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }

    // MARK: - UI
    private func setupUI() {
        [stepsView, completedView, prescribedView, daysInAppView].forEach { $0.layer.cornerRadius = 10 }
    }
    
    func configure(models: [TopAchievmentsModel]) {
        models.forEach { model in
            switch model.type {
            case .steps:
                stepsCountLabel.text = "\(model.count)"
                stepsDescriptionLabel.text = "days above 7k steps"
            case .daysIn:
                inAppCountLabel.text = "\(model.count)"
                inAppDescriptionLabel.text = "days in  the app"
            case .completed:
                completedCountLabel.text = "\(model.count)"
                completedDescriptionLabel.text = "daily tasks completed"
            case .prescribed:
                prescribedCountLabel.text = "\(model.count)"
                prescribedDescriptionLabel.text = "daily tasks prescribed"
            }
        }
    }
    
}
