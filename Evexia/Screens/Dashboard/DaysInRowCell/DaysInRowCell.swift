//
//  DaysInRowCell.swift
//  Evexia Staging
//
//  Created by Oleg Pogosian on 10.01.2022.
//

import UIKit
import Combine

class DaysInRowCell: UITableViewCell, CellIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var topTextLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var breakButton: RequestButton!
    @IBOutlet weak var bestResultLabel: UILabel!
    
    // MARK: - Properties
    var breakButtonDidTap = PassthroughSubject<Void, Never>()
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        iconImageView.image = nil
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.shadowView.layer.cornerRadius = 16.0
        self.shadowView.layer.masksToBounds = false
        self.shadowView.layer.shadowColor = UIColor.gray400.cgColor
        self.shadowView.layer.shadowRadius = 20.0
        self.shadowView.layer.shadowOpacity = 0.5
        self.shadowView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
    }
    
    private func setupUI() {
        breakButton.setTitle("Take a break", for: .normal)
        breakButton.layer.cornerRadius = 20
    }
    
    func configurateCell(type: DashboardSectionType, data: StepsClass?) {
        guard let model = data else { return }
        
        if type == .walk {
            topTextLabel.text = "You have walked 7,000 steps for:"
            iconImageView.image = UIImage(named: "shoe")
        } else if type == .completedTasks {
            topTextLabel.text = "You didn't miss completing your tasks:"
            iconImageView.image = UIImage(named: "completedTasks")
        }
        let days = model.personalRecord == 1 ? "day" : "days"
        bestResultLabel.text = "Best result: \(model.personalRecord) " + days
        countLabel.text = "\(model.score)"
        
        daysLabel.text = model.score == 1 ? "Day in a row" : "Days in a row"
    }
    
    // MARK: - IBActions
    @IBAction func breakButtonAction(_ sender: Any) {
//        UIView.transition(with: self,
//                          duration: 0.5,
//                          options: .curveEaseIn,
//                          animations: {
//            self.alpha = 0
//        }) { _ in
//            self.removeFromSuperview()
//        }
        self.breakButtonDidTap.send()
    }
    
}
