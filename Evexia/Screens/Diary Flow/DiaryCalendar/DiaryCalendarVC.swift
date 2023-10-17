//
//  DiaryCalendarVC.swift
//  Evexia
//
//  Created by admin on 06.09.2021.
//

import Foundation
import JTAppleCalendar
import UIKit
import Combine

final class DiaryCalendarVC: BaseViewController, StoryboardIdentifiable {
    
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var calendar: JTACMonthView!
    
    internal var viewModel: DiaryCalendarVM!
    private let calendarCellSize: CGFloat = 48.0
    private var cancellables = Set<AnyCancellable>()

    // - Base
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.binding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.calendar.scrollToHeaderForDate(Date())

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.calendar.layoutIfNeeded()
    }
    
    private func binding() {
        self.viewModel.dataSource
            .sink(receiveValue: { [weak self] _ in
                self?.calendar.reloadData()
            }).store(in: &cancellables)
    }
    
    private func setupUI() {
        self.view.backgroundColor = .white
        self.calendar.calendarDelegate = self
        self.calendar.calendarDataSource = self
        self.calendar.cellSize = self.calendarCellSize
        self.calendar.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

        self.calendar.register(DayViewCell.nib, forCellWithReuseIdentifier: DayViewCell.identifier)
        self.calendar.register(MonthReusableView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MonthReusableView.identifier)

        self.roundedView.layer.cornerRadius = 44.0
    }
    
    @IBAction func closeButtonDidTap(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - JTACMonthViewDataSource
extension DiaryCalendarVC: JTACMonthViewDataSource {
    
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let startDate = Date().minus(months: 3)
        let endDate = Date().plus(years: 1)
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!

        return ConfigurationParameters(startDate: startDate,
                                       endDate: endDate,
                                       numberOfRows: 6,
                                       calendar: calendar,
                                       generateInDates: .forAllMonths,
                                       generateOutDates: .tillEndOfRow,
                                       firstDayOfWeek: .monday)
    }
}

// MARK: - JTACMonthViewDelegate
extension DiaryCalendarVC: JTACMonthViewDelegate {
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: DayViewCell.identifier, for: indexPath) as! DayViewCell
        let modelForDay = self.viewModel.dataSource.value.first(where: { Date(timeIntervalSince1970: $0.timestamp / 1_000).compare(.isSameDay(as: date)) })
        cell.config(model: cellState, modelForDay: modelForDay)
        if date.compare(.isSameDay(as: Date())) {
            cell.layer.zPosition = 1
        } else {
            cell.layer.zPosition = 0
        }
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = cell as! DayViewCell
        let isNeedShowDot = self.viewModel.dataSource.value.first(where: { Date(timeIntervalSince1970: $0.timestamp / 1_000).compare(.isSameDay(as: date)) })
        cell.config(model: cellState, modelForDay: isNeedShowDot)
    }
    
    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: MonthReusableView.identifier, for: indexPath) as! MonthReusableView
        header.config(date: range.start)
        return header
    }
    
    func calendarSizeForMonths(_ calendar: JTACMonthView?) -> MonthSize? {
        return MonthSize(defaultSize: 112.0)
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        self.viewModel.selectedDate.send(date)
        self.dismiss(animated: true, completion: nil)
    }
    
    func calendar(_ calendar: JTACMonthView, shouldSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool {
        return true
    }
    
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
    
    }
}
