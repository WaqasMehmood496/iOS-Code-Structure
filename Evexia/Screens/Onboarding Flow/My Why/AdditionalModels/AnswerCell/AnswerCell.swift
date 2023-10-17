//
//  AnswerCell.swift
//  Evexia
//
//  Created by  Artem Klimov on 13.07.2021.
//

import UIKit
import Combine

class AnswerCell: UITableViewCell, CellIdentifiable {
    
    @IBOutlet weak var checkbox: Checkbox!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    
    private var cancellables = Set<AnyCancellable>()
    
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
    
    func configCell(model: MyWhyModel) {
        
        self.titleLabel.text = model.title
        
        if model.isSelected.value {
            self.isSelected = model.isSelected.value
            self.checkbox.selected()
        }
        
        model.selectionAvailabel
            .sink(receiveValue: { [weak self] isAvailabelSelection in
                self?.isUserInteractionEnabled = isAvailabelSelection
            }).store(in: &self.cancellables)
        
        self.checkbox.isSelectedPublisher
            .sink(receiveValue: { isSelected in
                model.isSelected.send(isSelected)
            }).store(in: &self.cancellables)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()

        if self.checkbox.isSelected {
            self.checkbox.selected()
        }
    }
    
    private func selected(_ isSelected: Bool) {
        self.checkbox.isSelected = !isSelected
        self.checkbox.selected()
    }
}
