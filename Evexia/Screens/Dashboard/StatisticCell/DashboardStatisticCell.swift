//
//  StatisticCell.swift
//  Evexia
//
//  Created by admin on 16.09.2021.
//

import UIKit
import Charts
import Segmentio
import Foundation
import Combine

class DashboardStatisticCell: UITableViewCell, CellIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var statsChartView: BarChartView!
    @IBOutlet private weak var typeSegmentedControl: Segmentio!
    @IBOutlet private weak var nextPeriodButton: UIButton!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var previousPeriodButton: UIButton!
    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var eatIndicatorView: UIView!
    @IBOutlet private weak var eatLabel: UILabel!
    @IBOutlet private weak var moveIndicatorView: UIView!
    @IBOutlet private weak var moveLabel: UILabel!
    @IBOutlet private weak var feelIndicatiorView: UIView!
    @IBOutlet private weak var feelLabel: UILabel!
    @IBOutlet private weak var connectIndicatorView: UIView!
    @IBOutlet private weak var connectLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.setupUI()
        self.binding()
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
    
    // MARK: - Properties
    var cancellables: [AnyCancellable] = []
    var showNext = PassthroughSubject<Void, Never>()
    var showPrevious = PassthroughSubject<Void, Never>()
    var curentFilterType = PassthroughSubject<StatsDateType, Never>()

    func setupUI() {
        setupStatsView()
        setupSegmentedControll()
        [eatIndicatorView, moveIndicatorView, feelIndicatiorView, connectIndicatorView].forEach { $0?.layer.cornerRadius = 2 }
    }
    
    func configCell(data: [WeelbeingStatisticModel]?, currentDistance: CurrentValueSubject<String, Never>) {
        
        guard let data1 = data else { return }
        let dates = data1.map { $0.date }
        let move = data1.map { $0.move }
        let feel = data1.map { $0.feel }
        let connect = data1.map { $0.disconnect }
        let eat = data1.map { $0.eat }
    
        var moveEntries: [BarChartDataEntry] = []
        var feelEntries: [BarChartDataEntry] = []
        var connectEntries: [BarChartDataEntry] = []
        var eatEntries: [BarChartDataEntry] = []
        for i in 0..<dates.count {
            let moveEntrie = BarChartDataEntry(x: Double(i), y: move[i].value)
            moveEntries.append(moveEntrie)
            let feelEntrie = BarChartDataEntry(x: Double(i), y: feel[i].value)
            feelEntries.append(feelEntrie)
            let connectEntrie = BarChartDataEntry(x: Double(i), y: connect[i].value)
            connectEntries.append(connectEntrie)
            let eatEntrie = BarChartDataEntry(x: Double(i), y: eat[i].value)
            eatEntries.append(eatEntrie)
        }
        
        let mSet = BarChartDataSet(moveEntries)
        mSet.drawValuesEnabled = false
        mSet.colors = move.map { setBarColor(stat: $0) }
    
        let fSet = BarChartDataSet(feelEntries)
        fSet.drawValuesEnabled = false
        fSet.colors = feel.map { setBarColor(stat: $0) }
        
        let cSet = BarChartDataSet(connectEntries)
        cSet.drawValuesEnabled = false
        
        cSet.colors = connect.map { setBarColor(stat: $0) }
        let eSet = BarChartDataSet(eatEntries)
        eSet.drawValuesEnabled = false
        
        eSet.colors = eat.map { setBarColor(stat: $0) }
        
        let dataSet = [fSet, eSet, mSet, cSet]
        
        currentDistance
            .sink(receiveValue: { [weak self] value in
                self?.dateLabel.text = value
            }).store(in: &cancellables)
        
        show(dataSet, dates: dates)
    }
    
    func setBarColor(stat: FocusStatisticModel) -> UIColor {
        return stat.inactive ? .gray300 : stat.type.tintColor
    }
    
    func binding() {

    }
    
    // MARK: - IBActions
    @IBAction func previousButtonDidTap(_ sender: Any) {
        self.showPrevious.send()
    }
    
    @IBAction func nextButtonDidTap(_ sender: Any) {
        self.showNext.send()
    }
    
    private func setupStatsView() {
        statsChartView.noDataText = "No data available"
        statsChartView.noDataFont = UIFont(name: "NunitoSans-Semibold", size: 16)!
        statsChartView.noDataTextColor = .gray900
        typeSegmentedControl.layer.cornerRadius = 16.0
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
    
    func show(_ stats: [BarChartDataSet], dates: [String]) {
        // Setup X axis
        let xAxis = statsChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = false
        xAxis.granularityEnabled = true
        xAxis.setLabelCount(dates.count, force: false)
        xAxis.valueFormatter = IndexAxisValueFormatter(values: Array(dates))
        xAxis.centerAxisLabelsEnabled = true

       // xAxis.axisMaximum = Double(dates.count)
        xAxis.axisLineColor = .gray500
        xAxis.labelTextColor = .gray500
        
        // Setup left axis
        let leftAxis = statsChartView.leftAxis
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawGridLinesEnabled = true
        leftAxis.drawTopYLabelEntryEnabled = true
        leftAxis.granularityEnabled = false
        leftAxis.drawLabelsEnabled = false
        leftAxis.axisLineColor = .gray500
        leftAxis.gridLineCap = CGLineCap.butt
        leftAxis.gridLineDashLengths = [1.5]
        leftAxis.gridLineDashPhase = 2
        leftAxis.axisMinimum = 0.0
        leftAxis.axisMaximum = 1.0
        leftAxis.setLabelCount(3, force: true)
        
        // Remove right axis
        let rightAxis = statsChartView.rightAxis
        rightAxis.enabled = false
        let barData = BarChartData(dataSets: stats)
        
        let groupSpace = 0.18
        let barSpace = 0.025
        let barWidth = 0.18
        // (0.15 + 0.05) * 4 + 0.2 = 1.00 -> interval per "group"
        
        let groupCount = dates.count
        let startYear = 0
        
        barData.barWidth = barWidth
        statsChartView.xAxis.axisMinimum = Double(startYear)
        
        let gg = barData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
        statsChartView.xAxis.axisMaximum = Double(startYear) + gg * Double(groupCount)
        
        barData.groupBars(fromX: Double(startYear), groupSpace: groupSpace, barSpace: barSpace)
        
        statsChartView.renderer = BarChartRenderer(dataProvider: statsChartView, animator: statsChartView.chartAnimator, viewPortHandler: statsChartView.viewPortHandler)
        statsChartView.data = barData
        
        if stats.isEmpty {
            self.statsChartView.data = nil
            self.statsChartView.legend.resetCustom()
            self.statsChartView.setNeedsDisplay()
        } else {
            self.statsChartView.notifyDataSetChanged()
        }
    }
    
    private func setupSegmentedControll() {
        
        let options = SegmentioOptions(
            backgroundColor: .clear,
            segmentPosition: .fixed(maxVisibleItems: 3),
            scrollEnabled: false,
            indicatorOptions: SegmentioIndicatorOptions(type: .bottom, ratio: 1.0, height: 3.0, color: .orange),
            horizontalSeparatorOptions: SegmentioHorizontalSeparatorOptions(type: .bottom, height: 0.0, color: .gray300),
            verticalSeparatorOptions: SegmentioVerticalSeparatorOptions(ratio: 0, color: .clear),
            imageContentMode: .center,
            labelTextAlignment: .center,
            segmentStates: (defaultState:
                                SegmentioState(backgroundColor: .clear, titleFont: UIFont(name: "NunitoSans-Semibold", size: 18.0)!, titleTextColor: .gray900, titleAlpha: 1.0),
                            selectedState: SegmentioState(backgroundColor: .clear, titleFont: UIFont(name: "NunitoSans-Semibold", size: 18.0)!, titleTextColor: .orange, titleAlpha: 1.0),
                            highlightedState: SegmentioState(backgroundColor: .clear, titleFont: UIFont(name: "NunitoSans-Semibold", size: 18.0)!, titleTextColor: .orange, titleAlpha: 1.0))
        )
        
        var content = [SegmentioItem]()
        
        let week = SegmentioItem(title: "Week".localized(), image: nil)
        let month = SegmentioItem(title: "Month".localized(), image: nil)
        let year = SegmentioItem(title: "Year".localized(), image: nil)
        typeSegmentedControl.selectedSegmentioIndex = 0
        content = [week, month, year]
        
        typeSegmentedControl.setup(
            content: content,
            style: .onlyLabel,
            options: options
        )
        
        typeSegmentedControl.valueDidChange = { [weak self] _, segmentIndex in
            guard let filter = StatsDateType(rawValue: segmentIndex) else { return }
            self?.curentFilterType.send(filter)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()
    }
}

// MARK: - ChartViewDelegate
extension DashboardStatisticCell: ChartViewDelegate {
    
}
