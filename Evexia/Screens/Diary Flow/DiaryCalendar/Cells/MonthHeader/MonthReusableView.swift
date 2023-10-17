//
//  MonthReusableView.swift
//  Evexia
//
//  Created by admin on 06.09.2021.
//

import UIKit
import JTAppleCalendar

class MonthReusableView: JTACMonthReusableView, CellIdentifiable {

    // - IBOutlet
    @IBOutlet var titleLabel: UILabel!
    
    // - Base
    override func awakeFromNib() {
        super.awakeFromNib()
        self.config()
    }

    // - Internal BL
    func config(date: Date) {
        self.titleLabel.text = date.toString(style: .monthYear)
    }
    
    // - Private BL
    private func config() {
        self.titleLabel.textColor = .gray900
    }
    
}
