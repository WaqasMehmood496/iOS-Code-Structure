//
//  DiaryWeekCell.swift
//  Evexia
//
//  Created by admin on 07.09.2021.
//

import UIKit
import JTAppleCalendar

class DiaryWeekCell: JTACDayCell, CellIdentifiable {
    
    // IBOutlets
    @IBOutlet weak var weekDayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dotView: RoundedView!
    
    // MARK: - Properties
    private var modelForDay: DayTasksModel?
    private var hideDot = false
    
    // MARK: - LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.contentView.layer.cornerRadius = 12.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        self.contentView.clipsToBounds = true

        self.layer.shadowColor = UIColor.gray400.withAlphaComponent(0.5).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 10.0
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 12.0).cgPath
        self.clipsToBounds = false
    }
    
    override var isSelected: Bool {
        didSet {
            self.selectStatus(isSelected)
        }
    }
    
    internal func config(model: CellState, modelForDay: DayTasksModel?) {
        self.weekDayLabel.text = model.date.toString(style: .shortWeekday)
        self.dateLabel.text = model.date.toString(style: .monthDay)
        self.modelForDay = modelForDay

        if let data = self.modelForDay?.data {
            self.hideDot = !data.contains(where: { $0.isSelected.value })
        } else {
            self.hideDot = true
        }
        self.selectStatus(isSelected)
    }
    
    private func selectStatus(_ isSelected: Bool) {
        if isSelected {
            self.superview?.bringSubviewToFront(self)
            self.dateLabel.textColor = .orange
            self.weekDayLabel.textColor = .orange
            self.dateLabel.font = UIFont(name: "NunitoSans-Semibold", size: 12.0)
            self.weekDayLabel.font = UIFont(name: "NunitoSans-Bold", size: 14.0)
            self.dotView.alpha = 0.0
            self.layer.shadowOpacity = 1.0
            self.layer.zPosition = 100
        } else {
            self.layer.shadowOpacity = 0.0
            if self.modelForDay != nil && !self.hideDot {
                self.dateLabel.textColor = .gray700
                self.weekDayLabel.textColor = .gray700
                self.dateLabel.font = UIFont(name: "NunitoSans-Regular", size: 12.0)
                self.weekDayLabel.font = UIFont(name: "NunitoSans-Semibold", size: 14.0)
                self.dotView.alpha = self.hideDot ? 0 : 1
                self.layer.zPosition = 0
            } else {
                self.dateLabel.textColor = .gray500
                self.weekDayLabel.textColor = .gray500
                self.dateLabel.font = UIFont(name: "NunitoSans-Regular", size: 12.0)
                self.weekDayLabel.font = UIFont(name: "NunitoSans-Semibold", size: 14.0)
                self.dotView.alpha = 0.0
                self.layer.zPosition = 0
            }
        }
    }
}
