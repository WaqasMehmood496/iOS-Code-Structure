//
//  DevelopmentCell.swift
//  Evexia
//
//  Created by admin on 29.11.2021.
//

import UIKit

class DevelopmentCell: UITableViewCell, CellIdentifiable {

    @IBOutlet weak var comingSoonLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var developmentImageView: UIImageView!
    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var imageBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        setupUI()
    }
    
    private func setupUI() {
        comingSoonLabel.rotate(radians: .pi / 4)
        cornerView.layer.cornerRadius = 16.0
        cornerView.layer.masksToBounds = true
        shadowView.layer.shadowColor = UIColor.gray400.cgColor
        shadowView.layer.shadowRadius = 8.0
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.shadowOffset = .zero
        shadowView.layer.shadowPath = UIBezierPath(rect: shadowView.bounds).cgPath
        
        imageBackgroundView.layer.cornerRadius = imageBackgroundView.frame.height / 2.0
    }
    
    func configCell(with model: SelfDevelopment) {
        titleLabel.text = model.title
        developmentImageView.image = UIImage(named: model.imageKey)
        
        if model == .development || model == .achievments {
            if model == .achievments && !UserDefaults.isShowAchieve {
                self.cornerView.alpha = 0.7
                self.shadowView.alpha = 0.5
            } else {
                self.cornerView.alpha = 1
                self.shadowView.alpha = 1
            }
            comingSoonLabel.isHidden = true
        } else {
            comingSoonLabel.isHidden = false
            self.cornerView.alpha = 1
            self.shadowView.alpha = 1
        }
    }
}
