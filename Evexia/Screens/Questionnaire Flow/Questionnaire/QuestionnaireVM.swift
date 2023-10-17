//
//  QuestionnaireVM.swift
//  Evexia
//
//  Created by admin on 24.09.2021.
//

import Foundation
import Combine

class QuestionnaireVM {
    
    // MARK: - Properties
    internal var dataSource = CurrentValueSubject<[QuestionnaireSection], Never>([])
    internal var errorPublisher = PassthroughSubject<ServerError, Never>()
    internal var isQuestionnaireCompleted = CurrentValueSubject<Bool, Never>(false)
    internal var surveyType: SurveyType
    internal var questionnaire: CurrentValueSubject<QuestionnaireModel, Never>
    internal var isRequestAction = PassthroughSubject<Bool, Never>()
    
    private let repository: QuestionnaireRepositoryProtocol
    private let router: QuestionnaireNavigation
    private var cancellables = Set<AnyCancellable>()
    private var answers = Set<AnswerRequestModel>()
    
    init(router: QuestionnaireNavigation, repository: QuestionnaireRepositoryProtocol, surveyType: SurveyType, model: QuestionnaireModel) {
        self.router = router
        self.repository = repository
        self.surveyType = surveyType
        self.questionnaire = CurrentValueSubject<QuestionnaireModel, Never>(model)
        self.binding()
        self.configDataSource(from: model)
    }
    
    internal func addAnswer(_ answer: AnswerRequestModel) {
        self.answers.remove(answer)
        self.answers.insert(answer)
        
        if self.answers.count == dataSource.value.count {
            self.isQuestionnaireCompleted.send(true)
        }
    }
    
    internal func completeSurvey() {
        switch self.surveyType {
        case .pulse:
            self.completePulseSurvey()
        case .wellbeing:
            self.completeWellbeingSurvey()
        }
    }
    
    private func binding() {
//        switch self.surveyType {
//        case .pulse:
//            self.loadPulseSurvey()
//        case .wellbeing:
//            self.loadWellbeingSurvey()
//        }
    }
    
//    private func loadPulseSurvey() {
//        self.repository.getPulse()
//            .sink(receiveCompletion: { [weak self] completion in
//                self?.applyRequestCompletion(completion)
//            }, receiveValue: { [weak self] questionnaireModel in
//                self?.questionnaire.send(questionnaireModel)
//                self?.configDataSource(from: questionnaireModel)
//            }).store(in: &cancellables)
//    }
//
//    private func loadWellbeingSurvey() {
//        self.repository.getWellbeing()
//            .sink(receiveCompletion: { [weak self] completion in
//                self?.applyRequestCompletion(completion)
//            }, receiveValue: { [weak self] questionnaireModel in
//                self?.questionnaire.send(questionnaireModel)
//                self?.configDataSource(from: questionnaireModel)
//            }).store(in: &cancellables)
//    }
    
    private func completePulseSurvey() {
        let questionnaire = self.questionnaire.value
        let requestModel = QuestionnaireRequestModel(list: Array(self.answers))
        self.repository.completePulse(with: requestModel, questionareId: questionnaire.id)
            .sink(receiveCompletion: { [weak self] completion in
                self?.applyRequestCompletion(completion)
            }, receiveValue: { [weak self] _ in
                self?.showResults(for: nil)
            }).store(in: &cancellables)
    }
    
    private func completeWellbeingSurvey() {
        
        let questionnaire = self.questionnaire.value
        let requestModel = QuestionnaireRequestModel(list: Array(self.answers))
        self.repository.completeWellbeing(with: requestModel, questionareId: questionnaire.id)
            .sink(receiveCompletion: { [weak self] completion in
                self?.applyRequestCompletion(completion)
            }, receiveValue: { [weak self] score in
                self?.showResults(for: score)
            }).store(in: &cancellables)
    }
    
    private func configDataSource(from data: QuestionnaireModel) {
        var sections = [QuestionnaireSection]()
        
        for question in data.list {
            switch question.type {
            case .radio:
                let sectionModels: [QuestionnaireSectionDataType] = question.answers.map { .radio($0) }
                let section = QuestionnaireSection(title: .radio, data: sectionModels, question: question)
                sections.append(section)
            case .range:
                let sectionModel: QuestionnaireSectionDataType = .range(question)
                let section = QuestionnaireSection(title: .radio, data: [sectionModel], question: question)
                sections.append(section)
            }
        }
        self.dataSource.send(sections)
    }
    
    private func applyRequestCompletion(_ completion: Subscribers.Completion<ServerError>) {
        switch completion {
        case let .failure(error):
            self.isRequestAction.send(false)
            self.errorPublisher.send(error)
        case .finished:
            self.isRequestAction.send(false)
        }
    }
    
    private func showResults(for score: Int?) {
        let result: WellbeingScore? = .getScoreLevel(for: score)
        NotificationCenter.default.post(name: .surveyDone, object: result)
        self.router.closeView()
    }
}
