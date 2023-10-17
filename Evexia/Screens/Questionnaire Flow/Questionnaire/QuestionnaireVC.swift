//
//  QuestionnaireVC.swift
//  Evexia
//
//  Created by admin on 24.09.2021.
//

import Foundation
import UIKit
import Combine

class QuestionnaireVC: BaseViewController, StoryboardIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var questionnaireTable: IntrinsicTableView!
    @IBOutlet private weak var completeQuestionnaireButton: RequestButton!

    // MARK: - Properties
    internal var viewModel: QuestionnaireVM!

    private lazy var dataSource = self.configDataSource()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.binding()
    }
    
    // MARK: - Private methods
    private func setupUI() {
        self.view.showActivityIndicator()
        self.completeQuestionnaireButton.isHidden = true
        self.setupTableView()
    }
    
    private func setupTableView() {
        self.questionnaireTable.dataSource = self.dataSource
        self.questionnaireTable.delegate = self
        self.questionnaireTable.register(AnswerRadioCell.nib, forCellReuseIdentifier: AnswerRadioCell.identifier)
        self.questionnaireTable.register(AnswerRangeCell.nib, forCellReuseIdentifier: AnswerRangeCell.identifier)
        self.questionnaireTable.register(QuestionnaireHeaderView.nib, forHeaderFooterViewReuseIdentifier: QuestionnaireHeaderView.identifier)

        self.questionnaireTable.allowsSelection = true
        self.questionnaireTable.allowsMultipleSelection = true
        self.questionnaireTable.showsVerticalScrollIndicator = false
        self.questionnaireTable.isScrollEnabled = true
        self.questionnaireTable.separatorStyle = .none
        self.questionnaireTable.estimatedRowHeight = UITableView.automaticDimension
        self.questionnaireTable.rowHeight = UITableView.automaticDimension
        self.questionnaireTable.sectionHeaderHeight = UITableView.automaticDimension
        self.questionnaireTable.estimatedSectionHeaderHeight = 100.0
        
        self.questionnaireTable.sectionFooterHeight = 0.0
        
        if #available(iOS 15.0, *) {
            self.questionnaireTable.sectionHeaderTopPadding = 0
        }
    }
    
    private func binding() {
        self.viewModel.dataSource
            .sink(receiveValue: { [weak self] data in
                self?.update(with: data)
            }).store(in: &cancellables)
        
        self.viewModel.errorPublisher
            .sink(receiveValue: { [weak self] serverError in
                self?.view.removeActivityIndicator()
                self?.modalAlert(modalStyle: serverError.errorCode)
            }).store(in: &cancellables)
        
        self.viewModel.isQuestionnaireCompleted
            .sink(receiveValue: { [weak self] isCompleted in
                self?.completeQuestionnaireButton.isEnabled = isCompleted
            }).store(in: &cancellables)
        
        self.viewModel.questionnaire
            .sink(receiveValue: { [weak self] questionnaire in
                guard let self = self else { return }
                self.titleLabel.text = self.viewModel.surveyType.title
            }).store(in: &cancellables)
        
        self.viewModel.isRequestAction
            .sink(receiveValue: { [weak self] isRequested in
                self?.completeQuestionnaireButton.isRequestAction.send(isRequested)
            }).store(in: &cancellables)
    }
}

// MARK: - IBAction
extension QuestionnaireVC {
    @IBAction func closeButtonDidTap(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func competeQuestionnaire(_ sender: RequestButton) {
        self.viewModel.completeSurvey()
    }
}

// MARK: - QuestionnaireVC: UITableViewDelegate
extension QuestionnaireVC: UITableViewDelegate {
    
    func update(with sections: [QuestionnaireSection], animate: Bool = false) {
        
        DispatchQueue.main.async { [weak self] in
            var snapshot = QuestionnaireSnaphot()
            
            snapshot.appendSections(sections)
            sections.forEach { section in
                snapshot.appendItems(section.data, toSection: section)
            }
            
            self?.dataSource.apply(snapshot, animatingDifferences: animate)
            
            if !sections.isEmpty {
                self?.view.removeActivityIndicator()
                self?.completeQuestionnaireButton.isHidden = false
            }
        }
    }
    
    private func configDataSource() -> QuestionnaireDataSource {
        let dataSource = QuestionnaireDataSource(tableView: self.questionnaireTable, cellProvider: { [unowned self] tableView, indexPath, model in
            
            switch model {
            case let .radio(model):
                let cell = tableView.dequeueReusableCell(withIdentifier: AnswerRadioCell.identifier, for: indexPath) as! AnswerRadioCell
                cell.configCell(answer: model)
                return cell
                
            case let .range(model):
                let cell = tableView.dequeueReusableCell(withIdentifier: AnswerRangeCell.identifier, for: indexPath) as! AnswerRangeCell
                cell.configCell(with: model)

                cell.answerPublisher
                    .sink(receiveValue: { [weak self] answer in
                        self?.viewModel.addAnswer(answer)
                    }).store(in: &self.cancellables)
                return cell
            }
        })
        
        return dataSource
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: QuestionnaireHeaderView.identifier) as? QuestionnaireHeaderView else { return nil }
        
        let sectionModel = self.dataSource.snapshot().sectionIdentifiers[section]
        header.configHeader(with: sectionModel.question, index: section)
        return header
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let selectedIndexPath = tableView.indexPathsForSelectedRows?.first(where: {
            $0.section == indexPath.section
        }) {
            tableView.deselectRow(at: selectedIndexPath, animated: false)
        }
        return indexPath
    }

    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
        let answer = section.question.answers[indexPath.row]
        if section.type == .radio {
            let answerModel = AnswerRequestModel(id: section.question.id, answerId: answer.id)
            self.viewModel.addAnswer(answerModel)
        }
    }
}
