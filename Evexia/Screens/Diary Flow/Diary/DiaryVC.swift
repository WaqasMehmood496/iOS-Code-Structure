//
//  DiaryVC.swift
//  Evexia
//
//  Created by admin on 06.09.2021.
//

import Foundation
import UIKit
import Combine
import JTAppleCalendar
import SwiftEntryKit

final class DiaryVC: BaseViewController, StoryboardIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var selectedWeekMonthLabel: UILabel!
    @IBOutlet private weak var calendar: JTACMonthView!
    @IBOutlet private weak var myGoalsLabel: UILabel!
    @IBOutlet private weak var editTasksButton: UIButton!
    @IBOutlet private weak var todayButton: UIButton!
    @IBOutlet private weak var tasksTable: IntrinsicTableView!
    @IBOutlet weak var editDescriptionLabel: UILabel!
    @IBOutlet weak var saveChangesButton: RequestButton!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var rewritePlanButton: RequestButton!
    
    // MARK: - Properties
    internal var viewModel: DiaryVM!
    
    private lazy var dataSource = self.configDataSource()
    private var cancellables = Set<AnyCancellable>()
    private var isStarted = false
    private lazy var overlayTutorial: OverlayTutorialController = { OverlayTutorialController()
    }()
    private var models: [DiaryTaskCellModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
        viewModel.getPlan()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calendar.scrollToDate(Date().toZeroTime(), animateScroll: false, preferredScrollPosition: .bottom)
        calendar.selectDates([Date().toZeroTime()])
        (self.tabBarController as? TabBarController)?.setTabBarHidden(false, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: false)
        checkTutorialStatus()
    }
    
    override func viewWillDisappear (_ animated: Bool) {
        super.viewWillDisappear(animated)
        (self.tabBarController as? TabBarController)?.customTabBar.isUserInteractionEnabled = true
    }
    
    private func checkTutorialStatus() {
        guard UserDefaults.needShowDiaryTutorial else { return }
        
        UserDefaults.$currentTutorial
            .print()
            .sink(receiveValue: { tutarial in
                guard tutarial == nil else { return }
                (self.tabBarController as? TabBarController)?.customTabBar.isUserInteractionEnabled = true
            }).store(in: &cancellables)
    }
    
    private func setupUI() {
        view.layoutIfNeeded()
        self.calendar.calendarDataSource = self
        self.calendar.calendarDelegate = self
        self.calendar.scrollingMode = .stopAtEachCalendarFrame
        self.calendar.cellSize = ((calendar.frame.width - 48.0) / 7.0)
        self.calendar.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        self.calendar.clipsToBounds = false
        self.calendar.minimumLineSpacing = 0
        self.calendar.minimumInteritemSpacing = 0
        self.calendar.register(DiaryWeekCell.nib, forCellWithReuseIdentifier: DiaryWeekCell.identifier)
        self.calendar.showsHorizontalScrollIndicator = false
        self.tasksTable.register(DiaryTaskCell.nib, forCellReuseIdentifier: DiaryTaskCell.identifier)
        self.tasksTable.rowHeight = UITableView.automaticDimension
        self.tasksTable.estimatedRowHeight = UITableView.automaticDimension
        self.tasksTable.dataSource = dataSource
        self.tasksTable.delegate = self
        self.tasksTable.separatorStyle = .none
        self.tasksTable.showsVerticalScrollIndicator = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "calendar"), style: .plain, target: self, action: #selector(navigateToCalendar(_:)))
        self.title = "Diary"
        setupButtons()
        
        calendar.reloadData()
    }
    
    func setupButtons() {
        rewritePlanButton.backgroundColor = .clear
        rewritePlanButton.layer.borderWidth = 1.0
        rewritePlanButton.layer.borderColor = UIColor.gray500.cgColor
    }
    
    @objc
    func navigateToCalendar(_ sender: Any?) {
        self.viewModel.navigateToCalendar()
    }
    
    private func configDataSource() -> TasksDataSource {
        let dataSource = TasksDataSource(tableView: self.tasksTable, cellProvider: { tableView, indexPath, model in
            let cell = tableView.dequeueReusableCell(withIdentifier: DiaryTaskCell.identifier, for: indexPath) as! DiaryTaskCell
            
            cell.configCell(with: model)
            
            cell.selectionHandler = { [weak self] in
                guard let self = self else { return }
                
                var count = 0
                self.models.forEach { element in
                    if element.isSelected.value {
                        count += 1
                    }
                }
                if count < 4 {
                    model.isSelected.value.toggle()
                    cell.setButtonImage()
                } else if model.isSelected.value {
                    model.isSelected.value.toggle()
                    cell.setButtonImage()
                }
            }
            
            cell.taskCellAction.sink(receiveValue: { [weak self] model, action in
                self?.viewModel.applyPerform(for: model, action: action)
            }).store(in: &cell.cancellables)
            return cell
        })
        
        return dataSource
    }
    
    private func binding() {
        self.viewModel.selectedDate
            .removeDuplicates()
            .sink(receiveValue: { [weak self] date in
                
                self?.updateAccording(to: date)
                if date.compare(.isSameDay(as: Date())) {
                    self?.todayButton.isHidden = true
                } else {
                    self?.todayButton.isHidden = false
                }
                self?.todayButton.fadeTransition(0.2)
            }).store(in: &cancellables)
        
        self.viewModel.selectedDateTasks
            .sink(receiveValue: { [weak self] models in
                self?.update(with: models)
                self?.emptyView.isHidden = !models.isEmpty
                self?.calendar.reloadDates( self?.calendar.visibleDates().monthDates.map { $0.date } ?? [])
            }).store(in: &cancellables)
        
        self.viewModel.diaryMode.sink(receiveValue: { [weak self] mode in
            switch mode {
            case .edit:
                self?.setEditStatus()
            case .normal:
                self?.setNormalStatus()
            }
        }).store(in: &cancellables)
        
        self.viewModel.isShowAchivementView
            .delay(for: .seconds(0.3), scheduler: RunLoop.current, options: .none)
            .sink(receiveValue: { [weak self] isShow, state in
                guard let self = self else { return }
                if self.isViewLoaded && (self.view.window != nil) && isShow {
                    self.showAchievementPopUp(type: state, action: self.viewModel.navigateToPersonalPlan)
                }
            }).store(in: &cancellables)
        
        self.viewModel.isFirstTaskCompleted
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] isShow, state in
                guard let self = self else { return }
                if self.isViewLoaded && (self.view.window != nil) && isShow {
                    self.showAchievementPopUp(type: state, action: {})
                }
            }).store(in: &cancellables)
        
        UserDefaults.$countDailyTasks
            .sink { [weak self] dailyTasks in
                if let dailyTasks = dailyTasks {
                    self?.checkIfAlertShownToday(dailyTasks: dailyTasks)
                }
            }.store(in: &cancellables)
    }
    
    func dismissAlert() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            self.dismissEnrtyKitAlert()
        }
    }
    
    private func updateAccording(to date: Date) {
        self.selectedWeekMonthLabel.text = date.toString(style: .month)
        self.calendar.scrollToDate(date, animateScroll: true, preferredScrollPosition: .bottom)
        self.calendar.selectDates([date])
        if date.compare(.isLater(than: Date())) {
            if viewModel.diaryMode.value == .normal {
                self.editTasksButton.isHidden = false
            } else {
                self.editTasksButton.isHidden = true
            }
        } else {
            self.editTasksButton.isHidden = true
        }
    }
    
    private func enableEditing() {
        rewritePlanButton.isHidden = true
        self.saveChangesButton.isHidden = false
        self.editTasksButton.isHidden = true
        self.editDescriptionLabel.isHidden = false
        self.view.layoutIfNeeded()
        
    }
    
    private func update(with data: [DiaryTaskCellModel]) {
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            var snapshot = NSDiffableDataSourceSnapshot<Int, DiaryTaskCellModel>()
            snapshot.appendSections([0])
            snapshot.appendItems(data)
            self.dataSource.apply(snapshot, animatingDifferences: false) {
                self.models = data
                self.showTutorial(with: data)
            }
        }
        models = data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [unowned self] in
            if !self.isStarted {
                self.isStarted = true
                
                if UserDefaults.currentTutorial != nil && !data.isEmpty {
                    guard let cell = self.tasksTable.cellForRow(at: IndexPath(item: 0, section: 0)) else { return }
                    let frame = self.tasksTable.convert(cell.frame, to: self.view)
                    
                    DispatchQueue.main.async {
                        self.overlayTutorial.showInViewController(self, for: frame)
                    }
                    
                } else {
                    self.isStarted = false
                }
            }
        })
    }
    
    private func showTutorial(with data: [DiaryTaskCellModel]) {
        if !isStarted {
            isStarted = true
            if UserDefaults.currentTutorial != nil && !data.isEmpty, let cell = self.tasksTable.cellForRow(at: IndexPath(item: 0, section: 0)) {
                
                (self.tabBarController as? TabBarController)?.customTabBar.isUserInteractionEnabled = false
                let frame = self.tasksTable.convert(cell.frame, to: self.view)
                
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    self.overlayTutorial.showInViewController(self, for: frame)
                })
            } else {
                isStarted = false
            }
        }
    }
    
    private func setNormalStatus() {
        
        rewritePlanButton.isHidden = false
        self.saveChangesButton.isHidden = true
        self.editDescriptionLabel.isHidden = true
        self.editTasksButton.isHidden = false
        self.viewModel.selectedDateTasks.value.forEach { $0.isEditing.send(false) }
    }
    
    private func setEditStatus() {
        self.enableEditing()
    }
}

// IBActions
extension DiaryVC {
    
    @IBAction func editButtonDidTap(_ sender: UIButton) {
        self.viewModel.selectedDateTasks.value.forEach { $0.isEditing.send(true) }
        self.viewModel.diaryMode.send(.edit)
    }
    
    @IBAction func todayButtonDidTap(_ sender: UIButton) {
        self.viewModel.selectedDate.send(Calendar.current.startOfDay(for: Date()))
    }
    
    @IBAction func saveChangesButtonDidTap(_ sender: RequestButton) {
        self.viewModel.diaryMode.send(.normal)
        self.viewModel.updateSelectedTasks()
    }
    
    @IBAction func rewritePlanButtonDidTap(_ sender: UIButton) {
        self.modalAlert(modalStyle: ModalAlertViewStyles.rewritePlan, completion: { [weak self] in
            self?.viewModel.navigateToPersonalPlan()
        }, cancel: {})
    }
}

// MARK: - JTACMonthViewDataSource
extension DiaryVC: JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let startDate = Date().minus(months: 3)
        let endDate = Date().plus(years: 1)
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 1, calendar: calendar, generateInDates: .forFirstMonthOnly, generateOutDates: .off, firstDayOfWeek: .monday)
    }
}

// MARK: - JTACMonthViewDelegate
extension DiaryVC: JTACMonthViewDelegate {
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: DiaryWeekCell.identifier, for: indexPath) as! DiaryWeekCell
        let modelForDay = self.viewModel.dataSource.value.model.first(where: { Date(timeIntervalSince1970: $0.timestamp / 1_000).compare(.isSameDay(as: date)) })
        cell.config(model: cellState, modelForDay: modelForDay)
        
        return cell
        
    }
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = cell as! DiaryWeekCell
        let modelForDay = self.viewModel.dataSource.value.model.first(where: { Date(timeIntervalSince1970: $0.timestamp / 1_000).compare(.isSameDay(as: date.toZeroTime())) })
        cell.config(model: cellState, modelForDay: modelForDay)
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        self.viewModel.selectedDate.send(cellState.date)
    }
    
    func calendar(_ calendar: JTACMonthView, shouldSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool {
        return true
        
    }
}

// MARK: DiaryVC - UITableViewDelegate
extension DiaryVC: UITableViewDelegate {
}

class TasksDataSource: UITableViewDiffableDataSource<Int, DiaryTaskCellModel> {
    
}

extension DiaryVC {
    private func checkIfAlertShownToday(dailyTasks: Int) {
        guard let type = viewModel.showDailyTaskAchivment(dailyTasks: dailyTasks), !type.isShow else { return }
        type.changeIsShow()
        showAchivments(type: .completedDailyTask(type))
    }
    
    private func showAchivments(type: AchievementViewType) {
        DispatchQueue.main.async {
            self.showAchievementPopUp(type: type) { [weak self] in
                if type.isDailyTaskAchievement {
                    self?.viewModel.navigateToAchievementView()
                }
            }
        }
    }
}
