//
//  AnswerRadioCell.swift
//  Evexia
//
//  Created by admin on 25.09.2021.
//

import UIKit
import Combine

class AnswerRadioCell: UITableViewCell, CellIdentifiable {

    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var answerLabel: UILabel!
    @IBOutlet private weak var checkbox: Checkbox!
        
    private var model: AnswerModel?
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
        
        self.shadowView.layer.shadowRadius = 6.0
        self.shadowView.layer.cornerRadius = 8.0
        self.shadowView.layer.shadowColor = UIColor.gray400.cgColor
        self.shadowView.layer.shadowOpacity = 0.5
        self.shadowView.layer.borderColor = UIColor.gray300.cgColor
        self.shadowView.layer.borderWidth = 1.0
        self.shadowView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.shadowView.layer.masksToBounds = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()

        if self.checkbox.isSelected {
            self.checkbox.selected()
        }
    }
    
    internal func configCell(answer: AnswerModel) {
        
        self.answerLabel.text = answer.title
        
        self.checkbox.isSelectedPublisher
            .sink(receiveValue: { [weak self] isSelected in
                if isSelected {
                    self?.model?.isSelected = isSelected
                }
            }).store(in: &self.cancellables)
    }
    
    private func selected(_ isSelected: Bool) {
        self.checkbox.isSelected = !isSelected
        self.checkbox.selected()
    }
}
