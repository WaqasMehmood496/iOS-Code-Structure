//
//  ProgressCell.swift
//  Evexia
//
//  Created by admin on 12.09.2021.
//

import UIKit

class ProgressCell: UITableViewCell, CellIdentifiable {

    @IBOutlet weak var dailyGoalsLabel: UILabel!
    @IBOutlet weak var weeklyGoalsLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!

    @IBOutlet weak var weeklyValueLabel: UILabel!
    @IBOutlet weak var dailyValueLabel: UILabel!
    @IBOutlet weak var statisticView: CircularProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func configCell(for model: WeekStatistic?) {
        guard let model1 = model else { return }

        var dayGoalValue = Double(model1.dailyCompleted) / Double(model1.countOfDaily)
        var weekGoalValue = Double(model1.weeklyCompleted) / Double(model1.countOfWeekly)
        
        dayGoalValue = dayGoalValue.isNaN ? 0.0 : dayGoalValue
        
        weekGoalValue = weekGoalValue.isNaN ? 0.0 : weekGoalValue
        
        self.weeklyValueLabel.text = "\(Int(weekGoalValue * 100.0))%"
        self.dailyValueLabel.text = "\(Int(dayGoalValue * 100.0))%"

        self.statisticView.dayProgress = CGFloat(dayGoalValue)
        self.statisticView.weekProgress = CGFloat(weekGoalValue)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.shadowView.layer.cornerRadius = 16.0
        self.shadowView.layer.masksToBounds = false
        self.shadowView.layer.shadowColor = UIColor.gray400.cgColor
        self.shadowView.layer.shadowRadius = 14.0
        self.shadowView.layer.shadowOpacity = 0.5
        self.shadowView.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
    }
}
