//
//  DaySliderCell.swift
//  Evexia
//
//  Created by  Artem Klimov on 20.07.2021.
//

import UIKit
import Combine

class DaySliderCell: UITableViewCell, CellIdentifiable {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeSlider: TimeSlider!
    @IBOutlet weak var trackView: UIView!
    
    private var cancellables = Set<AnyCancellable>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.trackView.layer.cornerRadius = 2.0
        self.trackView.layer.masksToBounds = true
    }
    
    func configCell(with model: DaySliderCellModel) {
        self.dayLabel.text = model.day.title
        self.timeSlider.value = Float(model.value.value)
        
        self.timeSlider.currentValue
            .sink(receiveValue: { value in
                model.value.send(Int(value))
            }).store(in: &self.cancellables)
    }
}
