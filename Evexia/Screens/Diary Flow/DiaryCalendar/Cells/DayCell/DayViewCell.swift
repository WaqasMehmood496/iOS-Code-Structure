//
//  DayCell.swift
//  Evexia
//
//  Created by admin on 06.09.2021.
//

import UIKit
import JTAppleCalendar

class DayViewCell: JTACDayCell, CellIdentifiable {
 
    // - IBOutlet
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet weak var dotView: UIView!
    
    // - Base
    override func awakeFromNib() {
        super.awakeFromNib()
        self.config()
    }

    // - Internal BL
    func config(model: CellState, modelForDay: DayTasksResponseModel?) {
        self.dateLabel.text = model.text
        if modelForDay != nil {
            self.dotView.alpha = 1.0
        } else {
            self.dotView.alpha = 0.0
        }

        if model.date.compare(.isSameDay(as: Date())) {
            self.superview?.bringSubviewToFront(self)
            self.layer.cornerRadius = 12.0

            self.contentView.layer.masksToBounds = true
            self.contentView.clipsToBounds = false
            
            self.layer.shadowColor = UIColor.gray400.withAlphaComponent(0.5).cgColor
            self.layer.shadowOffset = .zero
            self.layer.shadowRadius = 10.0
            self.layer.masksToBounds = false
            self.layer.shadowOpacity = 1.0
            self.clipsToBounds = false
        }
        
        if model.dateBelongsTo == .thisMonth {
            self.superview?.sendSubviewToBack(self)

            if model.date.compare(.isSameDay(as: Date())) {
                self.dateLabel.textColor = .orange
                self.dotView.alpha = 0.0
            } else {
                self.dateLabel.textColor = .gray700
            }
        } else {
            self.clipsToBounds = true
            self.dateLabel.textColor = .gray400
            self.dotView.alpha = 0.0
            if model.dateBelongsTo == .followingMonthWithinBoundary {
            } else {
                isHidden = false
            }
        }
    }
    
    // - Private BL
    private func config() {
        self.dotView.backgroundColor = .orange
        self.dotView.layer.masksToBounds = true
        self.dotView.layer.cornerRadius = 2
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.layer.shadowOpacity = 0.0
    }
}
