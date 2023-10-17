//
//  MyAvailabilityVC.swift
//  Evexia
//
//  Created by  Artem Klimov on 20.07.2021.
//

import UIKit
import Combine

class MyAvailabilityVC: BaseViewController, StoryboardIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var planDurationtDescriptionLabel: UILabel!
    @IBOutlet private weak var planDurationLabel: UILabel!
    @IBOutlet private weak var planDurationTimeLabel: UILabel!
    @IBOutlet private weak var dayAvailabilityLable: UILabel!
    @IBOutlet private weak var planDurationButton: UIButton!
    @IBOutlet private weak var daysTableView: UITableView!
    @IBOutlet private weak var setAvailabilityButton: RequestButton!
    @IBOutlet private weak var planDurationBackgroundView: UIView!
    
    // MARK: - Properties
    internal var viewModel: MyAvailabilityVMType!
    
    private var cancellables = Set<AnyCancellable>()
    private let load = PassthroughSubject<Void, Never>()
    private let setDuration = PassthroughSubject<Int?, Never>()
    private let setAvailability = PassthroughSubject<Void, Never>()
    
    private let rowHeight: CGFloat = 44.0
    private let cornerRadius: CGFloat = 16.0
    
    private lazy var dataSource = self.configDataSource()
    
    // MARK: - VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.binding()
        self.load.send()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "My availability".localized()
    }
}

// MARK: - Private Methods
private extension MyAvailabilityVC {
    func setupUI() {
        self.setupTableView()
        self.setupLabels()
        self.setupViews()
        (self.tabBarController as? TabBarController)?.setTabBarHidden(true, animated: false)
    }
    
    func setupTableView() {
        self.daysTableView.dataSource = self.dataSource
        self.daysTableView.delegate = self
        self.daysTableView.register(DaySliderCell.nib, forCellReuseIdentifier: DaySliderCell.identifier)
        self.daysTableView.register(MyAvailabilityHeaderView.nib, forHeaderFooterViewReuseIdentifier: MyAvailabilityHeaderView.identifier)
        self.daysTableView.register(EmptyFooterView.self, forHeaderFooterViewReuseIdentifier: EmptyFooterView.identifier)
        self.daysTableView.allowsSelection = false
        self.daysTableView.isScrollEnabled = false
        self.daysTableView.showsVerticalScrollIndicator = false
        self.daysTableView.separatorStyle = .none
        self.daysTableView.rowHeight = rowHeight
        
        if #available(iOS 15.0, *) {
            self.daysTableView.sectionHeaderTopPadding = 0
        }
    }
    
    func setupLabels() {
        self.planDurationtDescriptionLabel.text = "How long do you want your plan to run for?".localized()
        self.planDurationLabel.text = "Plan duration".localized()
        self.planDurationTimeLabel.text = "Not set".localized()
        self.dayAvailabilityLable.text = "How much time do you have?".localized()
        self.navigationItem.title = "Availability"
        var buttonTitle = ""
        switch viewModel.profileFlow {
        case .edit, .changePlanAfterEndPeriod: buttonTitle = "Save changes"
        case .onboarding: buttonTitle = "Ok, lets set up my profile"
            
        }
        self.setAvailabilityButton.setTitle(buttonTitle, for: .normal)

    }
    
    func setupViews() {
        self.planDurationBackgroundView.layer.cornerRadius = self.cornerRadius
        self.daysTableView.layer.cornerRadius = self.cornerRadius
        self.planDurationBackgroundView.dropShadow(shadowColor: .gray400)
    
    }
    
    func binding() {
        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()
        let input = MyAvailabilityVMInput(load: self.load.eraseToAnyPublisher(),
                                          setDuration: self.setDuration.eraseToAnyPublisher(),
                                          setAvailability: setAvailability.eraseToAnyPublisher())
        let output = viewModel.transform(input: input)
        
        output
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] state in
                self.render(state)
            }).store(in: &cancellables)
    }
    
    func render(_ state: MyAvailabilityVCState) {
        switch state {
        case let .idle(models):
            self.update(with: models)
            self.setAvailabilityButton.isRequestAction.send(false)
        case .loading:
            self.setAvailabilityButton.isRequestAction.send(true)
        case let .nextAvailabel(isAvailabel):
            self.setAvailabilityButton.isEnabled = isAvailabel
        case let .failure(serverError):
            self.modalAlert(modalStyle: serverError.errorCode)
            self.setAvailabilityButton.isRequestAction.send(false)
        case .success:
            self.setAvailabilityButton.isRequestAction.send(false)
        case let .getDuration(duration):
            self.planDurationTimeLabel.text = duration != nil ? PlanDuration(rawValue: duration!)?.title : "Not set"
        }
    }
    
    @IBAction func planDurationButtonDidTap(_ sender: UIButton) {
        let dataSource = PlanDuration.allCases.map { PickerDataModel(title: $0.title) }
        self.showPicker(style: dataSource, defaultSelected: self.planDurationTimeLabel.text, returns: { [weak self] returnedValue in
           
            let item = PlanDuration(string: returnedValue)
            self?.setDuration.send(item?.rawValue)
            self?.planDurationTimeLabel.text = item?.title
        })
    }
}

// MARK: - UITableViewDiffableDataSource<Int, MyWhyModel>
extension MyAvailabilityVC: UITableViewDelegate {
    
    func update(with data: [DaySliderCellModel], animate: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            var snapshot = NSDiffableDataSourceSnapshot<Int, DaySliderCellModel>()
            snapshot.appendSections([0])
            snapshot.appendItems(data)
            
            self?.dataSource.apply(snapshot, animatingDifferences: animate)
        }
    }
    
    func configDataSource() -> UITableViewDiffableDataSource<Int, DaySliderCellModel> {
        let dataSource = UITableViewDiffableDataSource<Int, DaySliderCellModel>(
            tableView: self.daysTableView,
            cellProvider: { tableView, indexPath, model in
                let cell = tableView.dequeueReusableCell(withIdentifier: DaySliderCell.identifier, for: indexPath) as! DaySliderCell
                cell.configCell(with: model)
                return cell
            }
        )
        return dataSource
    }
    
    internal func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    
    internal func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16.0
    }
    
    internal func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: MyAvailabilityHeaderView.identifier) as! MyAvailabilityHeaderView
        return header
    }
    
    internal func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return EmptyFooterView()
    }
}

// MARK: - IBAction
extension MyAvailabilityVC {
    @IBAction func setAvailabilityButtonDidTap(_ sender: RequestButton) {
        self.setAvailability.send()
    }
}
