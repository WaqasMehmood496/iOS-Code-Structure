//
//  DailyGoalCell.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 03.09.2021.
//

import UIKit
import Combine

// MARK: - DailyGoalCell
class DailyGoalCell: UITableViewCell, CellIdentifiable {

    // MARK: - IBOutlets
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var dailyGoalView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avarageStepsTitleLabel: UILabel!
    @IBOutlet weak var userCountStepLabel: UILabel!
    @IBOutlet weak var averageDailyCountStepsTitle: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    
    // MARK: - Properties
    let publishDailyGoalPublisher = PassthroughSubject<String, Never>()
    let removeDailyGoalPublisher = PassthroughSubject<Void, Never>()
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    // MARK: - Methods
    func config() -> DailyGoalCell {
        if let step = UserDefaults.stepsCount {
            userCountStepLabel.textColor = step > 5_000 ? .pink : .gray900
            userCountStepLabel.text = String(step)
        }
       
        return self
    }
   
    // MARK: - Action
    @IBAction func removeDailyGoal() {
        removeDailyGoalPublisher.send()
        setActionWithDailyGoal()
    }
    
    @IBAction func publishDailyPost() {
        publishDailyGoalPublisher.send(userCountStepLabel.text ?? "")
        setActionWithDailyGoal()
    }
}

// MARK: - Private Extension
private extension DailyGoalCell {
    func setupUI() {
        setupCornerView()
        setupDailyGoalView()
    }
    
    func setupCornerView() {
        cornerView.layer.cornerRadius = 16
    }
    
    func setupDailyGoalView() {
        setupBackGroundView()
        setupTitleLabel()
        setupAvarageStepsTitleLabel()
        setupAverageDailyCountStepsTitle()
        setupRemoveButton()
        setupPostButton()
    }
    
    func setupBackGroundView() {
        dailyGoalView.backgroundColor = UIColor(hex: "#F7FAFC")
        dailyGoalView.layer.borderWidth = 1
        dailyGoalView.layer.borderColor = UIColor(hex: "E2E8F0")?.cgColor
        dailyGoalView.layer.cornerRadius = 16
    }
    
    func setupTitleLabel() {
        titleLabel.text = "Smashed it! Just beat my average daily goal of 5,000 steps!".localized()
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .eatDark
    }
    
    func setupAvarageStepsTitleLabel() {
        avarageStepsTitleLabel.text = "Average steps / day".localized()
        avarageStepsTitleLabel.textAlignment = .center
        avarageStepsTitleLabel.textColor = .gray500
    }
    
    func setupAverageDailyCountStepsTitle() {
        averageDailyCountStepsTitle.text = " / 5000"
        averageDailyCountStepsTitle.textColor = .gray500
    }
    
    func setupRemoveButton() {
        removeButton.layer.borderWidth = 1
        removeButton.layer.borderColor =
            UIColor.gray500.cgColor
        removeButton.layer.cornerRadius = 16
        removeButton.backgroundColor = .white
        removeButton.setTitle("Remove", for: .normal)
        removeButton.titleLabel?.textColor = .black
        removeButton.titleLabel?.font = UIFont(name: "NunitoSans-Semibold", size: 20.0)!
    }
    
    func setupPostButton() {
        postButton.layer.cornerRadius = 16
        postButton.backgroundColor = .orange
        postButton.titleLabel?.textColor = .white
        postButton.titleLabel?.font = UIFont(name: "NunitoSans-Semibold", size: 20.0)!
        postButton.setTitle("Post", for: .normal)
    }
    
    func setActionWithDailyGoal() {
        UserDefaults.isShowDailyGoalView = false
        UserDefaults.oneDay = Date()
    }
}
