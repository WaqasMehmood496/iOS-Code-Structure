//
//  MoveGoalsCell.swift
//  Evexia
//
//  Created by admin on 12.09.2021.
//

import UIKit
import Charts
import Combine

class MoveGoalsCell: UITableViewCell, CellIdentifiable {

    // MARK: - IBOutlets
    
    @IBOutlet weak var moveGoalsLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var avarageStepsLabel: UILabel!
    @IBOutlet weak var statisticLabel: UILabel!
    @IBOutlet weak var statsChartView: BarChartView!
    @IBOutlet weak var weekDatesLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    
    internal var sharePublisher = PassthroughSubject<Void, Never>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none

        self.setupStatsView()
    }
    @IBAction func shareButtonDidTap(_ sender: Any) {
        NotificationCenter.default.post(name: .shareSteps, object: nil)
        self.shareButton.isHidden = true
    }
    
    func configCell(with statistic: [Stats]?) {
        
        guard let stat = statistic else { return }
        
        let activeStats = stat.filter { $0.inactive == false }
        let weekday = self.calculateWeekDay()
        let avarage = activeStats.compactMap { Double($0.score) }.reduce(0, +) / Double(weekday)
        let avarageInt: Int = avarage.isNaN ? 0 : Int(avarage)
         
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        let formattedString = formatter.string(for: Int(avarageInt))
        self.avarageStepsLabel.text = formattedString
        
        self.weekDatesLabel.text = generateRangeSring(for: stat)
        self.show(stat)
        self.isPassedMoreThan(days: 1, fromDate: UserDefaults.oneDay, toDate: Date())
        
        if UserDefaults.isShowDailyGoalView ?? true && avarageInt >= 5_000 {
            self.shareButton.isHidden = false
        } else {
            self.shareButton.isHidden = true
        }
    }
    
    private func calculateWeekDay() -> Int {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        return weekday == 1 ? 7 : weekday - 1
    }
    
    private func isPassedMoreThan(days: Int, fromDate date: Date?, toDate date2: Date) { // check how day passed (need to logic when show or hide dailyCell)
        let unitFlags: Set<Calendar.Component> = [.day]
        if let date = date, let deltaD = Calendar.current.dateComponents(unitFlags, from: date, to: date2).day, deltaD > days {
            UserDefaults.isShowDailyGoalView = true
        } else if date == nil {
            UserDefaults.isShowDailyGoalView = true
        }
        
    }
    
    private func setupStatsView() {
        statsChartView.noDataText = "No data available"
        statsChartView.noDataFont = UIFont(name: "NunitoSans-Semibold", size: 16)!
        statsChartView.noDataTextColor = .gray900
        statsChartView.delegate = self
        statsChartView.highlightPerTapEnabled = false
        statsChartView.highlightFullBarEnabled = false
        statsChartView.highlightPerDragEnabled = false
        statsChartView.legend.enabled = false
        statsChartView.fitBars = true
        statsChartView.pinchZoomEnabled = false
        statsChartView.setScaleEnabled(false)
        statsChartView.doubleTapToZoomEnabled = false
        statsChartView.drawBarShadowEnabled = false
        statsChartView.drawGridBackgroundEnabled = false
        statsChartView.drawBordersEnabled = false
        statsChartView.borderColor = .gray500
        statsChartView.animate(yAxisDuration: 1, easingOption: .linear)
    }
    
    func show(_ stats: [Stats]) {
        // Setup X axis
        let xAxis = statsChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = false
        xAxis.granularityEnabled = false
        xAxis.setLabelCount(stats.count, force: false)
        xAxis.valueFormatter = IndexAxisValueFormatter(values: Days.allCases.map { $0.title })
        xAxis.axisMaximum = Double(stats.count)
        xAxis.axisLineColor = .gray500
        xAxis.labelTextColor = .gray500
        statsChartView.leftAxis.enabled = false
        
        let leftAxis = statsChartView.rightAxis
        leftAxis.drawTopYLabelEntryEnabled = true
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = false
        leftAxis.axisLineColor = .gray500
        leftAxis.labelTextColor = .gray500
        leftAxis.gridLineCap = CGLineCap.butt
        leftAxis.gridLineDashLengths = [1.5]
        leftAxis.gridLineDashPhase = 2
        
        let value = stats.compactMap { Double($0.score) }
        let maxValue = value.max()
        leftAxis.axisMaximum = maxValue ?? 0
        leftAxis.valueFormatter = ChartFormatter(statisticType: .steps)
        
        leftAxis.setLabelCount(3, force: true)
        leftAxis.axisMinimum = 0.0
        
        // Remove right axis
        
        var entries: [BarItem] = []
        for (index, wellbeing) in stats.enumerated() {
            let entry = BarItem(index: index, value: Double(wellbeing.score)!)
            entries.append(entry)
        }
        let barChartEntries = entries.map { $0.transformToBarChartDataEntry() }
        let barChartSet = BarChartDataSet(entries: barChartEntries)
        barChartSet.axisDependency = .right
        let colors = stats.map { self.setBarColor(stat: $0) }
        barChartSet.colors = colors
        barChartSet.drawValuesEnabled = false
        
        let barData = BarChartData(dataSet: barChartSet)
        if stats.count == 7 {
            barData.barWidth = 0.8
        } else if stats.count > 7 {
            barData.barWidth = 0.5
        }
        statsChartView.renderer = BarChartRenderer(dataProvider: statsChartView, animator: statsChartView.chartAnimator, viewPortHandler: statsChartView.viewPortHandler)
        statsChartView.notifyDataSetChanged()
        statsChartView.data = barData
        
        if stats.allSatisfy({ $0.score == "0.0" }) {
            self.statsChartView.data = nil
            self.statsChartView.legend.resetCustom()
            self.statsChartView.setNeedsDisplay()
        } else {
            self.statsChartView.notifyDataSetChanged()
        }
    }
    
    func setBarColor(stat: Stats) -> UIColor {
        return stat.inactive ? .gray300 : .moveNew
    }
    
    private func generateRangeSring(for stats: [Stats]) -> String {
        let startDate = stats.first?.date ?? ""
        let endDate = stats.last?.date ?? ""
        return startDate + " - " + endDate
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.shadowView.layer.cornerRadius = 16.0
        self.shadowView.layer.masksToBounds = false
        self.shadowView.layer.shadowColor = UIColor.gray400.cgColor
        self.shadowView.layer.shadowRadius = 20.0
        self.shadowView.layer.shadowOpacity = 0.5
        self.shadowView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
    }
}

// MARK: - ChartViewDelegate
extension MoveGoalsCell: ChartViewDelegate {
    
}
