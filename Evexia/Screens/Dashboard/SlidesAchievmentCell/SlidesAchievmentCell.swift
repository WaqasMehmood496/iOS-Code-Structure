//
//  SlidesAchievmentCell.swift
//  Evexia
//
//  Created by Oleg Pogosian on 10.01.2022.
//

import UIKit
import Kingfisher

class SlidesAchievmentCell: UICollectionViewCell, CellIdentifiable {

    // MARK: - IBOutlets
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var achievIcon: UIImageView!
    @IBOutlet weak var achievDescriptionLabel: UILabel!
    @IBOutlet weak var achievProgressView: UIProgressView!
    @IBOutlet weak var currentProgressLabel: UILabel!
    @IBOutlet weak var stepsCountLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.mainView.layer.cornerRadius = 20.0
        self.mainView.layer.masksToBounds = false
        self.mainView.layer.shadowColor = UIColor.gray400.cgColor
        self.mainView.layer.shadowRadius = 20.0
        self.mainView.layer.shadowOpacity = 0.13
        self.mainView.layer.shadowOffset = CGSize(width: 0.7, height: 0.7)
    }
    
    private func setupUI() {
        self.layer.cornerRadius = 18
    }
    
    func configurateCell(model: BadgeSliderModel) {
        if model.icon == nil {
            achievIcon.image = UIImage(named: "activeStepAchieve")
            stepsCountLabel.text = "\(model.score)"
            if model.score != 0 {
                achievDescriptionLabel.text = "Wow, congratulations on your fabulous achievement! You have earned a new badge"
            } else {
                achievDescriptionLabel.text = "Log your first 7000 steps and leave your mark on climate change"
            }
            let steps = model.steps ?? 0
            if steps >= 7000 {
                currentProgressLabel.text = "7000/7000"
            } else {
                currentProgressLabel.text = "\(steps)/7000"
            }
            achievProgressView.progress = Float(steps) / 7000.0
        } else {
            let url = URL(string: model.icon!)!
            let resource = ImageResource(downloadURL: url)
            achievIcon.kf.setImage(with: resource)
            if model.score >= 20 {
                achievDescriptionLabel.text = "Wow, congratulations on your fabulous achievement! You have earned a new badge"
            } else {
                achievDescriptionLabel.text = "Make sure you tick off your daily habits in your diary to make a difference that counts!"
            }
            stepsCountLabel.isHidden = true
            currentProgressLabel.text = "\(model.score)/\(model.goal)"
            achievProgressView.progress = model.score != 0 ? Float(model.score) / Float(model.goal) : 0
        }
    }
}
