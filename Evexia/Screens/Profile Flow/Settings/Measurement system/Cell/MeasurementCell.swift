//
//  MeasurementCel.swift
//  Evexia
//
//  Created by Александр Ковалев on 15.11.2022.
//

import UIKit
import Combine

class MeasurementCell: UITableViewCell, CellIdentifiable {

    @IBOutlet weak var checkbox: Checkbox!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    
    private var cancellables = Set<AnyCancellable>()
    private var model: MeasurementSystemType = .us
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selected(selected)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.setupShadow()
    }
    
    private func setupShadow() {
        shadowView.layer.cornerRadius = 8.0
        shadowView.layer.shadowRadius = 6.0
        shadowView.layer.shadowOffset = .zero
        shadowView.layer.shadowColor = UIColor.gray400.cgColor
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 8.0).cgPath
    }
    
    func configCell(model: MeasurementSystemType) {
        self.model = model
        self.titleLabel.text = model.title
        
        checkbox.isSelectedPublisher
            .sink(receiveValue: { isSelected in
                if isSelected, UserDefaults.measurement != model.rawValue  {
                    UserDefaults.measurement = model.rawValue
                    
                    guard var user = UserDefaults.userModel else {
                        return
                    }
                    let weight = user.weight.changeMeasurementSystem(unitType: .mass).value
                    let height = user.height.changeMeasurementSystem(unitType: .lengh).value
                    user.weight = weight
                    user.height = height
                    
                    UserDefaults.userModel = user
                }
            }).store(in: &self.cancellables)
    }

    
    private func selected(_ isSelected: Bool) {
        self.checkbox.isSelected = !isSelected
        self.checkbox.selected()
    }
}
