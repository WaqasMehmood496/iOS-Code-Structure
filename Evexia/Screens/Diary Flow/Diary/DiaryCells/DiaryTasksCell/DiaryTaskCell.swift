//
//  DiaryTaskCell.swift
//  Evexia
//
//  Created by admin on 07.09.2021.
//

import UIKit
import Combine
import Atributika

enum TaskCellOptionStatus {
    case hidden
    case complited
    case option
}

enum TaskAction {
    case complete
    case overComplite
    case undo
    case skipTask
}

typealias TaskActionPublisher = PassthroughSubject<(DiaryTaskCellModel, TaskAction), Never>

class DiaryTaskCell: UITableViewCell, CellIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var focusImageView: UIImageView!
    @IBOutlet private weak var taskDescriptionLabel: UILabel!
    @IBOutlet private weak var periodicLabel: UILabel!
    @IBOutlet private weak var selectionButton: UIButton!
    @IBOutlet private weak var container: UIView!
    @IBOutlet private weak var compliteButton: UIButton!
    @IBOutlet private weak var optionButton: UIButton!
    
    @IBOutlet private weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var trailingConstraint: NSLayoutConstraint!
    
    internal var taskCellAction = TaskActionPublisher()
    
    private var optionStatus: TaskCellOptionStatus = .hidden
    
    private var buttonsTotalWidth: CGFloat {
        compliteButton.frame.maxX + 8.0
    }
    private let todayDate = Calendar.current.startOfDay(for: Date()).toZeroTime()
    
    // Properties
    var cancellables = Set<AnyCancellable>()
    
    private var paragraphStyle: NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5
        paragraphStyle.alignment = .left
        return paragraphStyle
    }
    
    private var descriptionStyle: Style {
        return Style()
            .paragraphStyle(self.paragraphStyle)
            .foregroundColor(.gray700, .normal)
            .font(UIFont(name: "NunitoSans-Regular", size: 16.0)!)
    }
    
    private var model: DiaryTaskCellModel! {
        didSet {
            self.setupUI()
            self.binding()
        }
    }
    var selectionHandler: (() -> Void)?
    
    // MARK: - LifeCycle
    internal override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.container.layer.cornerRadius = 8.0
        self.compliteButton.layer.cornerRadius = 8.0
        self.optionButton.layer.cornerRadius = 8.0
        
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(detectSwipe(_:)))
        swipeRecognizer.delegate = self
        swipeRecognizer.direction = .right
        self.container.addGestureRecognizer(swipeRecognizer)
        
        let leftswipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(detectSwipe(_:)))
        leftswipeRecognizer.delegate = self
        leftswipeRecognizer.direction = .left
        self.container.addGestureRecognizer(leftswipeRecognizer)
        self.clipsToBounds = false
        self.container.clipsToBounds = false

    }
    
    internal override func prepareForReuse() {
        super.prepareForReuse()
        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()
        self.setNormalStatus()
    }
    
    @IBAction private func selectionButtonDidTap(_ sender: UIButton) {
//        self.model.isSelected.value = !self.model.isSelected.value
//        self.setButtonImage()
        selectionHandler?()
    }
    
    @IBAction private func optionButtonDidTap(_ sender: UIButton) {
        if self.model.status != .notCompleted {
            self.taskCellAction.send((self.model, .undo))
            self.model.status = self.model.status.undo()
            self.updateWithTaskStatus(self.model.status, animated: true)
            self.setNormalStatus()
        } else {
            self.taskCellAction.send((model, .skipTask))
        }
        
        if let tutorial = UserDefaults.currentTutorial, tutorial == .undoTask {
            UserDefaults.currentTutorial = nil
            UserDefaults.needShowDiaryTutorial = false
            return
        }
    }
    
    @IBAction private func compliteButtonDidTap(_ sender: UIButton) {
        self.model.status = .completed
        self.taskCellAction.send((self.model, .complete))
        self.setCompletedStatus(animated: true)
        self.setNormalStatus()
        if let tutorial = UserDefaults.currentTutorial, tutorial == .completeTask {
            UserDefaults.currentTutorial = .swipeLeft
            return
        }
    }
    
    @IBAction private func overComplitButtonDidTap(_ sender: Any) {
        self.model.status = .overCompleted
        self.taskCellAction.send((self.model, .overComplite))
        self.setCompletedStatus(animated: true)
        self.setNormalStatus()
        if let tutorial = UserDefaults.currentTutorial, tutorial == .completeTask {
            UserDefaults.currentTutorial = .swipeLeft
            return
        }
    }
    
    internal func configCell(with model: DiaryTaskCellModel) {
        self.model = model
        self.updateWithTaskStatus(model.status, animated: false)
    }
    
    // Private BL
    private func binding() {
        self.setButtonImage()
        
        self.model.isEditing
            .sink(receiveValue: { [weak self] isEditing in
                self?.selectionButton.isHidden = !isEditing
                if isEditing {
                    self?.setNormalStatus()
                }
            }).store(in: &self.cancellables)
    }
    
    private func setupUI() {
        self.focusImageView.image = UIImage(named: self.model.focus.image_key)
        self.taskDescriptionLabel.attributedText = self.model.description.style(tags: self.descriptionStyle).attributedString
        self.periodicLabel.text = self.model.periodic.capitalized
    }
    
     func setButtonImage() {
        self.selectionButton.setImage(UIImage(named: self.model.isSelected.value ? "checkbox_on" : "checkbox_off"), for: .normal)
    }
    
    private func updateWithTaskStatus(_ status: TaskStatus, animated: Bool) {
        status == .notCompleted ? self.setUncolpletedStatus(animated: animated) : self.setCompletedStatus(animated: animated)
    }
    
    @objc
    private func detectSwipe(_ recognizer: UISwipeGestureRecognizer) {
        guard !self.model.isEditing.value else { return }
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let modelDate = Date(timeIntervalSince1970: model.timestamp / 1_000)
        
        if todayDate > modelDate {
            return
        }
        
        switch recognizer.direction {
        case .right:
            if let tutorial = UserDefaults.currentTutorial {
                switch optionStatus {
                case .hidden:
                    if tutorial == .start {
                        guard model.status == .notCompleted else { return }
                        self.showComplitedStatus()
                        UserDefaults.currentTutorial = .completeTask
                     }
                     return
                case .option:
                   return
                default:
                    break
                }
                return
            }
            
            switch optionStatus {
            case .hidden:
                guard model.status == .notCompleted else { return }

                if modelDate.compare(.isSameDay(as: todayDate)) {
                    self.showComplitedStatus()
                }
            case .option:
                self.setNormalStatus()
            default:
                break
            }
        case .left:
            if let tutorial = UserDefaults.currentTutorial {
                switch optionStatus {
                case .hidden:
                   if tutorial == .swipeLeft {
                        self.showOptionStatus()
                       UserDefaults.currentTutorial = .undoTask
                    }
                    return
                case .complited:
                    if tutorial == .completeTask {
                        return
                     }
                    self.setNormalStatus()
                default:
                    break
                }
                return
            }

            switch optionStatus {
            case .hidden:
                self.showOptionStatus()
            case .complited:
                self.setNormalStatus()
            default:
                break
            }
        default:
            break
        }
    }
    
    private func setCompletedStatus(animated: Bool) {
        self.container.backgroundColor = .gray200
        self.container.layer.borderWidth = 1.0
        self.container.layer.borderColor = UIColor.gray300.cgColor
        self.container.layer.shadowOpacity = 0
        if animated {
            self.container.fadeTransition(0.2)
        }
    }
    
    private func setUncolpletedStatus(animated: Bool) {
        self.container.backgroundColor = .white
        self.container.layer.borderWidth = 0.0
        self.container.layer.shadowColor = UIColor.gray400.cgColor
        self.container.layer.shadowRadius = 4.0
        self.container.layer.shadowOpacity = 0.4
        self.container.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        if animated {
            self.container.fadeTransition(0.2)
        }
    }
    
    private func setNormalStatus() {
        self.modifyShadow(for: optionButton, show: false)
        self.modifyShadow(for: compliteButton, show: false)

        self.optionStatus = .hidden
        
        UIView.animate(withDuration: 0.2, animations: {
            self.trailingConstraint.constant = 16.0
            self.leadingConstraint.constant = 16.0
            self.layoutIfNeeded()
        })
    }
    
    private func showComplitedStatus() {
        self.optionStatus = .complited
        self.modifyShadow(for: compliteButton, show: true)

        UIView.animate(withDuration: 0.2, animations: {
            self.leadingConstraint.constant = self.buttonsTotalWidth
            self.trailingConstraint.constant = -self.buttonsTotalWidth
            self.layoutIfNeeded()
        })
    }
    
    private func showOptionStatus() {
        self.optionStatus = .option
        self.optionButton.backgroundColor = model.status != .notCompleted ? UIColor(named: "eatNew") : UIColor(named: "error")
        let image = model.status != .notCompleted ? UIImage(named: "undo") : UIImage(named: "close")
        self.optionButton.setImage(image, for: .normal)
        self.optionButton.tintColor = .white
        self.modifyShadow(for: optionButton, show: true)
        UIView.animate(withDuration: 0.2, animations: {
            self.leadingConstraint.constant = -(self.optionButton.frame.width + 24.0)
            self.trailingConstraint.constant = self.optionButton.frame.width + 24.0
            self.layoutIfNeeded()
        })
    }

    private func modifyShadow(for button: UIButton, show: Bool) {
        button.layer.shadowColor = button.backgroundColor?.cgColor
        button.layer.shadowRadius = 3.0
        button.layer.shadowOpacity = show ? 0.5 : 0.0
        button.layer.shadowOffset = .zero
    }
}
