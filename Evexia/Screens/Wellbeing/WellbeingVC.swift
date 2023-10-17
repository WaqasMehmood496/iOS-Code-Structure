//
//  WellbeingVC.swift
//  Evexia Staging
//
//  Created by Roman Korostenskyi on 26.08.2021.
//

import UIKit
import Segmentio
import Combine
import Charts

final class WellbeingVC: BaseViewController, StoryboardIdentifiable {

    // MARK: - IBOutlets
    @IBOutlet private weak var statsView: UIView!
    @IBOutlet private weak var statsChartView: BarChartView!
    @IBOutlet private weak var typeSegmentedControl: Segmentio!
    @IBOutlet weak var entitiesView: UIView!
    
    @IBOutlet weak var weightButton: UIButton!
    @IBOutlet weak var nextPeriodButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var previousPeriodButton: UIButton!
    
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var weightStackView: UIView!
    @IBOutlet weak var entriesStackView: UIStackView!
    @IBOutlet weak var weightTableView: IntrinsicTableView!
    
    // MARK: - Properties
    var viewModel: WellbeingVM!
    
    private var cancellables: [AnyCancellable] = []
    
    private lazy var dataSource = self.configDataSource()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.binding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.tabBarController as? TabBarController)?.setTabBarHidden(false, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        statsView.layer.cornerRadius = 16.0
    }
    
    // MARK: - IBActions
    @IBAction func weightButtonDidTap(_ sender: UIButton) {
        self.viewModel.navigateToSetWeight()
    }
    
    @IBAction func previousButtonDidTap(_ sender: Any) {
        self.viewModel.showPrevious()
    }
    
    @IBAction func nextButtonDidTap(_ sender: Any) {
        self.viewModel.showNext()
    }
    
}

// MARK: - Private methods
private extension WellbeingVC {
    
    func setupUI() {
        self.navigationItem.title = self.viewModel.statisticType.title
        setupStatsView()
        setupSegmentedControll()
        self.setupTableView()
        self.setHideStatus()
    }
    
    func binding() {
        
        self.viewModel.intervalValue
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] distance in
                self?.dateLabel.text = distance
            }).store(in: &cancellables)
        
        self.viewModel.dataSource
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] stats in
                self?.show(stats)
            }).store(in: &cancellables)
        
        self.viewModel.entriesDataSource
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] stats in
                self?.update(with: stats)
            }).store(in: &cancellables)
        
        self.viewModel.user
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] user in
                guard let user = user else {
                    return
                }
                
                let string = (user.weight).isEmpty ? "Not set" : user.weight.getUnitWithSybmols(unitType: .mass)
                self?.weightLabel.text = string
            }).store(in: &cancellables)
    }
    
    private func update(with data: [Stats]) {
        DispatchQueue.main.async { [weak self] in
            var snapshot = NSDiffableDataSourceSnapshot<Int, Stats>()
            snapshot.appendSections([0])
            snapshot.appendItems(data)
            
            self?.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    private func setupStatsView() {
        self.statsChartView.noDataText = "No data available"
        self.statsChartView.noDataFont = UIFont(name: "NunitoSans-Semibold", size: 16)!
        self.statsChartView.noDataTextColor = .gray900
        self.weightStackView.layer.cornerRadius = 16.0
        self.entitiesView.layer.cornerRadius = 16.0
        statsView.layer.cornerRadius = 16.0
        typeSegmentedControl.layer.cornerRadius = 16.0
        statsView.dropShadow(radius: statsView.layer.cornerRadius, xOffset: 0.0, yOffset: 1.0, shadowOpacity: 0.2, shadowColor: .gray400)
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
    
    private func setupTableView() {
        self.weightTableView.register(WeightStatisticCell.nib, forCellReuseIdentifier: WeightStatisticCell.identifier)
        self.weightTableView.showsVerticalScrollIndicator = false
        self.weightTableView.rowHeight = 40.0
        self.weightTableView.estimatedRowHeight = 40.0
    }
    
    func configDataSource() -> UITableViewDiffableDataSource<Int, Stats> {
        let dataSource = UITableViewDiffableDataSource<Int, Stats>(
            tableView: self.weightTableView,
            cellProvider: { tableView, indexPath, model in
                let cell = tableView.dequeueReusableCell(withIdentifier: WeightStatisticCell.identifier, for: indexPath) as! WeightStatisticCell
                cell.configCell(with: model)
                return cell
            }
        )
        return dataSource
    }
    
    private func setHideStatus() {
        if self.viewModel.statisticType == .weight {
            self.entriesStackView.isHidden = false
            self.weightStackView.isHidden = false
            self.weightButton.isHidden = false
        }
    }
    
    func show(_ stats: [Stats]) {
        // Setup X axis
        let xAxis = statsChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = false
        xAxis.granularityEnabled = false
        xAxis.setLabelCount(stats.count, force: false)
        xAxis.valueFormatter = IndexAxisValueFormatter(values: stats.map { $0.date })
        xAxis.axisMaximum = Double(stats.count)
        xAxis.axisLineColor = .gray500
        xAxis.labelTextColor = .gray500
        
        // Setup left axis
        let leftAxis = statsChartView.leftAxis
        leftAxis.drawTopYLabelEntryEnabled = true
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = false
        leftAxis.axisLineColor = .gray500
        leftAxis.labelTextColor = .gray500
        leftAxis.gridLineCap = CGLineCap.butt
        leftAxis.gridLineDashLengths = [1.5]
        leftAxis.gridLineDashPhase = 2
        leftAxis.valueFormatter = ChartFormatter(statisticType: self.viewModel.statisticType)
        
        leftAxis.setLabelCount(3, force: true)
        leftAxis.axisMinimum = 0.0
        let value = stats.compactMap { Double($0.score) }
        let maxValue = value.max()
        leftAxis.axisMaximum = Double(maxValue ?? 0)
        
        // Remove right axis
        let rightAxis = statsChartView.rightAxis
        rightAxis.enabled = false
        var entries: [BarItem] = []
        for (index, wellbeing) in stats.enumerated() {
            let entry = BarItem(index: index, value: Double(wellbeing.score)!)
            entries.append(entry)
        }
        let barChartEntries = entries.map { $0.transformToBarChartDataEntry() }
        let barChartSet = BarChartDataSet(entries: barChartEntries)
        
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
        return stat.inactive ? .gray300 : viewModel.statisticType.barTint
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
            self?.viewModel.curentFilterType.send(filter)
        }
    }
}

// MARK: - ChartViewDelegate
extension WellbeingVC: ChartViewDelegate {
    
}

final class ChartFormatter: AxisValueFormatter {
    
    private var statisticType: StatisticType
    
    init(statisticType: StatisticType) {
        self.statisticType = statisticType
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if axis is XAxis {
            return String(value)
        } else {
            if statisticType == .steps {
                if value >= 2_000 {
                    return String(Int(value / 1_000)) + "k"
                } else {
                    return String(format: "%.f", value)
                }
            } else if statisticType == .sleep {
                let value = Double(value)
                let dateFormatter = DateComponentsFormatter()
                dateFormatter.unitsStyle = .positional
                dateFormatter.zeroFormattingBehavior = .pad
                dateFormatter.allowedUnits = [.hour, .minute]
                
                let time = dateFormatter.string(from: value)
                return time ?? "00:00"
            } else {
                return String(Int(value))
            }
        }
    }
    
    func roundToHundred(x: Double) -> Int {
        return 100 * Int(round(x / 100.0))
    }
}
