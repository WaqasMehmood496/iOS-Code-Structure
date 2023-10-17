//
//  DashboardVC.swift
//  Evexia
//
//  Created by admin on 11.09.2021.
//

import Foundation
import UIKit
import Combine
import Swinject
import SnapKit

class DashboardVC: BaseViewController, StoryboardIdentifiable, UITableViewDelegate {
        
    // MARK: - IBOutlets
    @IBOutlet weak var dashboardTable: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupUI()
        binding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.tabBarController as? TabBarController)?.setTabBarHidden(false, animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.viewModel.updateProgress()
        
    }
    
    deinit {
        Log.info("deinit -> \(self)")
    }
    
    // MARK: - Properties
    var allCellHeights = [IndexPath: CGFloat]()
    typealias DataSource = UITableViewDiffableDataSource<DashboardSectionModel, DashboardSectionDataType>
    typealias Snapshot = NSDiffableDataSourceSnapshot<DashboardSectionModel, DashboardSectionDataType>
    internal var viewModel: DashboardVM!
    
    private var cancellables = Set<AnyCancellable>()
   
    private lazy var dataSource = self.configDataSource()
    private var badgesCellIndex: IndexPath?
    private var streakCellIndex: IndexPath?
    
    private func binding() {
        self.viewModel.subscribeOnFilterChanges()
        
        self.viewModel.dataSource
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] data in
                self?.update(with: data)
            }).store(in: &cancellables)
        
        self.viewModel.errorPublisher
            .sink(receiveValue: { [weak self] serverError in
                self?.modalAlert(modalStyle: serverError.errorCode)
            }).store(in: &cancellables)
    }
    
    private func setupTableView() {
        self.dashboardTable.delegate = self
        self.dashboardTable.dataSource = dataSource

        self.dashboardTable.showsVerticalScrollIndicator = false
        self.dashboardTable.separatorStyle = .none
        self.dashboardTable.register(SurveyCell.nib, forCellReuseIdentifier: SurveyCell.identifier)
        self.dashboardTable.register(MoveGoalsCell.nib, forCellReuseIdentifier: MoveGoalsCell.identifier)
        self.dashboardTable.register(ProgressCell.nib, forCellReuseIdentifier: ProgressCell.identifier)
        self.dashboardTable.register(DashboardStatisticCell.nib, forCellReuseIdentifier: DashboardStatisticCell.identifier)
        self.dashboardTable.register(DaysInRowCell.nib, forCellReuseIdentifier: DaysInRowCell.identifier)
        self.dashboardTable.register(AchievmentsSliderCell.nib, forCellReuseIdentifier: AchievmentsSliderCell.identifier)
        self.dashboardTable.rowHeight = UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.allCellHeights[indexPath] = cell.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.allCellHeights[indexPath] ?? UITableView.automaticDimension
    }
    
    func setupUI() {
        self.navigationItem.title = "Dashboard".localized()
    }
    
    private func checkTutorial() {
        if !UserDefaults.needShowDashBoardTutorial {
            UserDefaults.allDataInDashBoardIsLoad = false
            UserDefaults.needShowDashBoardTutorial = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.createHintModels()
            }
        }
    }
    
    func createHintModels() {
        
        let indexPath = badgesCellIndex ?? IndexPath(row: 0, section: 1)
        dashboardTable.scrollToRow(at: indexPath, at: .top, animated: false)
        let view = DashBoardTutorialView(hints: createTutorialHints(indexPaths: [indexPath]))
        
        view.scrollTo.sink(receiveValue: { [weak self] in
            guard let self = self else { return }
            let indexPath = self.streakCellIndex ?? IndexPath(row: 0, section: 5)
            self.dashboardTable.scrollToRow(at: indexPath, at: .middle, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let hints = self.createTutorialHints(indexPaths: [indexPath])
                view.hints += hints
                view.nextStep()
            }
        }).store(in: &cancellables)
        
        navigationController?.view.addSubview(view)
        
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // Datasource
    private func update(with sections: [DashboardSectionModel]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            var snapshot = Snapshot()
            snapshot.appendSections(sections)
            sections.forEach { section in
                if section.type == .survey, !section.data.isEmpty {
                    UserDefaults.allDataInDashBoardIsLoad = true
                }
                snapshot.appendItems(section.data, toSection: section)
            }
            
            if #available(iOS 15.0, *) {
                self.dataSource.applySnapshotUsingReloadData(snapshot) {
                    DispatchQueue.main.async {
                        if UserDefaults.allDataInDashBoardIsLoad {
                            self.checkTutorial()
                        }
                    }
                }
            } else {
                self.dataSource.apply(snapshot, animatingDifferences: false) {
                    if UserDefaults.allDataInDashBoardIsLoad {
                        self.checkTutorial()
                    }
                }
            }
        }
    }
    
    func configDataSource() -> DataSource {
        let dataSource = DataSource(
            tableView: self.dashboardTable,
            cellProvider: { [unowned self] tableView, indexPath, model in
            
                switch model {
                case let .slider(data):
                    let cell = tableView.dequeueReusableCell(withIdentifier: AchievmentsSliderCell.identifier, for: indexPath) as! AchievmentsSliderCell
                    cell.configurateCell(count: data?.count ?? 0, array: data ?? [])
                    badgesCellIndex = indexPath
                    return cell
                case let .survey(model):
                    let cell = tableView.dequeueReusableCell(withIdentifier: SurveyCell.identifier, for: indexPath) as! SurveyCell
                    cell.configCell(for: model)
                    cell.skipSurvey
                        .sink(receiveValue: { model in
                            self.viewModel.skipSurvey(model)
                        }).store(in: &cell.cancellables)
                    
                    cell.startSurvey
                        .sink(receiveValue: { model in
                            self.viewModel.startSurvey(model?.type)
                        }).store(in: &cell.cancellables)
                    return cell
                case let .progress(model):
                    let cell = tableView.dequeueReusableCell(withIdentifier: ProgressCell.identifier, for: indexPath) as! ProgressCell
                    cell.configCell(for: model)
                    return cell
                case let .walk(data):
                    let cell = tableView.dequeueReusableCell(withIdentifier: DaysInRowCell.identifier, for: indexPath) as! DaysInRowCell
                    cell.configurateCell(type: .walk, data: data)
                    cell.breakButton.isEnabled = self.checkEnabledTap()
                    cell.breakButtonDidTap
                        .receive(on: DispatchQueue.main)
                        .sink(receiveValue: { [weak self] _ in
                            self?.showBreakAlert(type: .steps)
                        }).store(in: &self.cancellables)
                    return cell
                case let .moveProgress(model):
                    let cell = tableView.dequeueReusableCell(withIdentifier: MoveGoalsCell.identifier, for: indexPath) as! MoveGoalsCell
                    cell.configCell(with: model)
                    return cell
                case let .completedTasks(data):
                    let cell = tableView.dequeueReusableCell(withIdentifier: DaysInRowCell.identifier, for: indexPath) as! DaysInRowCell
                    cell.configurateCell(type: .completedTasks, data: data)
                    cell.breakButton.isEnabled = self.checkEnabledTap()
                    cell.breakButtonDidTap
                        .receive(on: DispatchQueue.main)
                        .sink(receiveValue: { [weak self] _ in
                            self?.showBreakAlert(type: .dailyTasks)
                        }).store(in: &self.cancellables)
                    streakCellIndex = indexPath
                    return cell
                case let .statistic(data):
                    let cell = tableView.dequeueReusableCell(withIdentifier: DashboardStatisticCell.identifier, for: indexPath) as! DashboardStatisticCell
                    cell.configCell(data: data, currentDistance: viewModel.intervalValue)
                   
                    cell.showPrevious
                        .sink(receiveValue: { [weak self] in
                            self?.viewModel.showPrevious()
                        }).store(in: &cell.cancellables)
                    
                    cell.showNext
                        .sink(receiveValue: { [weak self] in
                            self?.viewModel.showNext()
                        }).store(in: &cell.cancellables)
                    
                    cell.curentFilterType
                        .sink(receiveValue: { [weak self] filter in
                            self?.viewModel.curentFilterType.send(filter)
                        }).store(in: &cell.cancellables)
                    return cell
                }
            }
        )
        return dataSource
    }
    
    private func showBreakAlert(type: BreaksType) {
        if self.view.subviews.contains(where: { $0.tag == 12345 }) {
            return
        }
        
//        self.navigationController?.navigationBar.alpha = 0
        
        weak var customAlert: TakeBreakAlertView? = .fromNib()
        customAlert?.tag = 12345
        customAlert?.alpha = 0
        customAlert?.frame = self.view.frame
        customAlert?.center = self.view.center
        customAlert?.configurate(breaksCount: self.viewModel.breaksCount)
        customAlert?.cancelButtonDidTap
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {
//                self?.navigationController?.navigationBar.alpha = 1
                customAlert?.removeFromSuperview()
            }).store(in: &self.cancellables)
        
        customAlert?.takeButtonDidTap
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.viewModel.takeBreak(type: type)
                customAlert?.removeFromSuperview()
            }).store(in: &self.cancellables)

        if customAlert != nil {
            self.view.addSubview(customAlert!)
        }
        
        customAlert?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        
        UIView.animate(withDuration: 0.3) {
            customAlert?.alpha = 1
            customAlert?.transform = CGAffineTransform.identity
        }
    }
    
    private func checkEnabledTap() -> Bool {
        if let storedDate = UserDefaults.storedDate, let toDate = Calendar.current.date(byAdding: .day, value: 1, to: storedDate) {
            
            let cliks = UserDefaults.numberOfClicks
            
            if Date() <= toDate {
                return cliks < 2 && viewModel.breaksCount > 0
            } else {
                // date exceed may be reset the date and cliks to 1
//                UserDefaults.storedDate = Date()
                UserDefaults.numberOfClicks = 1
                return viewModel.breaksCount > 0
            }
        }
        UserDefaults.numberOfClicks = 1
        
        return true
    }
    
    private func createTutorialHints(indexPaths: [IndexPath]) -> [HintsOverlayItem] {
        var hints: [HintsOverlayItem] = []
        
        //Daily tasks badges
        let image = UIImage(named: "close")!.withRenderingMode(.alwaysOriginal)
        
        indexPaths.forEach { indexPath in
            if let cell = dashboardTable.cellForRow(at: indexPath) as? AchievmentsSliderCell {
                let originRect = cell.convert(cell.bounds, to: view)
                let tempRect = cell.sliderCollectionView.convert(cell.sliderCollectionView.bounds, to: view)
                let rect = CGRect(origin: .init(x: tempRect.origin.x - 5, y: tempRect.origin.y - 5), size: .init(width: tempRect.size.width + 10, height: tempRect.size.height + 20))
                let title = "Daily tasks badges".localized()
                let subtitle = """
                Earn your badges by swiping right on completed daily tasks in your diary.
                
                You can switch off gamification in settings at any time. Alternatively participate anonymously!
                """.localized()
                
                hints = [
                    HintsOverlayItem(title: title, subTitle: subtitle, buttonImage: image, navHeight: navBarHeight, originRect: originRect, rect: rect)
                ]
            }
            
            //Streaks
            if let cell = dashboardTable.cellForRow(at: indexPath) as? DaysInRowCell {
                let originRect = cell.convert(cell.bounds, to: view)
                let tempRect = cell.shadowView.convert(cell.shadowView.bounds, to: view)
                let rect = CGRect(origin: .init(x: dashboardTable.frame.origin.x - 5, y: tempRect.origin.y - 5), size: .init(width: dashboardTable.bounds.width + 10, height: tempRect.size.height + 15))
                let title = "Streaks".localized()
                let subtitle = "Look how well you have done. Keep a log on many consecutive days you have done something fabulous for your planet and your health".localized()
                
                hints.append(HintsOverlayItem(title: title, subTitle: subtitle, buttonImage: image, navHeight: navBarHeight, originRect: originRect, rect: rect))
            }
            
            //Take a break
            if let cell = dashboardTable.cellForRow(at: indexPath) as? DaysInRowCell {
                let tempRect = cell.breakButton.convert(cell.breakButton.bounds, to: view)
                let originRect = CGRect(origin: .init(x: dashboardTable.frame.origin.x - 5, y: tempRect.origin.y - 5), size: .init(width: dashboardTable.bounds.width + 10, height: tempRect.size.height + 15))
                let title = "Take a break".localized()
                let subtitle = "Would you like to take a break from your streak? You have two “take a break” options to use per month".localized()
                
                hints.append(HintsOverlayItem(title: title, subTitle: subtitle, buttonImage: image, navHeight: navBarHeight, originRect: originRect, rect: originRect))
            }
        }
        
        return hints
    }
}
