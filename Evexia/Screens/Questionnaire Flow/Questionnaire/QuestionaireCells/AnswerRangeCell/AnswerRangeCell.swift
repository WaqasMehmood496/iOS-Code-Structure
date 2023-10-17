//
//  AnswerRangeCell.swift
//  Evexia
//
//  Created by admin on 25.09.2021.
//

import UIKit
import Combine

class AnswerRangeCell: UITableViewCell, CellIdentifiable {
    
    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var answersStackView: UIStackView!
    @IBOutlet private weak var cornerView: UIView!
    
    internal var answerPublisher = PassthroughSubject<AnswerRequestModel, Never>()
    internal var cancellables = Set<AnyCancellable>()

    private var cellModel: QuestionModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()
        self.answersStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.shadowView.layer.shadowColor = UIColor.gray400.cgColor
        self.shadowView.layer.shadowOpacity = 0.5
        self.shadowView.layer.borderColor = UIColor.gray400.cgColor
        self.shadowView.layer.borderWidth = 1.0
        self.shadowView.layer.shadowRadius = 6.0
        self.shadowView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.shadowView.layer.cornerRadius = 8.0

        self.cornerView.layer.cornerRadius = 8.0
        self.cornerView.layer.masksToBounds = true

    }
    
    func configCell(with model: QuestionModel) {
        self.cellModel = model
        let index = model.answers.firstIndex(where: { $0.isSelected == true })
        
        for i in (1...model.answers.count) {
            let button = AnswerButton(title: "\(i)")
            button.tag = i - 1
            button.addTarget(self, action: #selector(selectAction(_:)), for: .touchUpInside)
            self.answersStackView.addArrangedSubview(button)
            if button.tag == index {
                button.isSelected = true
            }
        }
    }

    @objc
    private func selectAction(_ sender: UIButton) {
        for view in answersStackView.arrangedSubviews {
            if let button = view as? AnswerButton {
                button.isSelected = false
            }
        }
        sender.isSelected = true
        let answerTag = sender.tag
        cellModel?.answers.forEach({ $0.isSelected = false })
        cellModel?.answers[answerTag].isSelected = true
        
        guard let question = self.cellModel else { return }
        self.answerPublisher.send(AnswerRequestModel(id: question.id, answerId: question.answers[answerTag].id))
    }
}
