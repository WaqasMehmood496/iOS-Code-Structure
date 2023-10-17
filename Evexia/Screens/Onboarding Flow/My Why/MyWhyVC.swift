//
//  MyGoalsVC.swift
//  Evexia
//
//  Created by  Artem Klimov on 08.07.2021.
//

import UIKit
import Combine
import Atributika

class MyWhyVC: BaseViewController, StoryboardIdentifiable, UIScrollViewDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var hintView: HintView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var myWhyTableView: IntrinsicTableView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var nextButton: RequestButton!
    @IBOutlet weak var hintHeight: NSLayoutConstraint!
    
    // MARK: - Properties
    internal var viewModel: MyWhyVMType!
    private var cancellables = Set<AnyCancellable>()
    private let load = PassthroughSubject<Void, Never>()
    private let nextAction = PassthroughSubject<Void, Never>()
    private var isNeedreload = true
    
    private var countLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 20.0, height: 20.0)
        label.textColor = .gray500
        label.font = UIFont(name: "NunitoSans-Semibold", size: 20.0)
        return label
    }()
    
    private var paragraphStyle: NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.0
        paragraphStyle.alignment = .center
        return paragraphStyle
    }
    
    private var titleStyle: Style {
        return Style()
            .foregroundColor(.gray900, .normal)
            .font(UIFont(name: "NunitoSans-Bold", size: 18.0)!)
            .custom(self.paragraphStyle, forAttributedKey: NSAttributedString.Key.paragraphStyle)
    }
    
    private lazy var dataSource = self.configDataSource()
    
    // MARK: - VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.binding()
        self.setupNavigationItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hintHeight.constant = 120
        self.nextButton.isUserInteractionEnabled = true
        if isNeedreload {
            self.load.send()
            isNeedreload = false
        }
        self.setupNavigationItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.visibleViewController?.navigationItem.rightBarButtonItem = nil
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        self.setupUI()
//        self.binding()
//    }
}

// MARK: - Private Methods
private extension MyWhyVC {
    func setupUI() {
        self.setupTableView()
        self.setupLabels()
        self.setupScrollView()
        
        self.hintView.isHidden = UserDefaults.hideMyWhysHint
    }
    
    func setupTableView() {
        self.myWhyTableView.dataSource = self.dataSource
        self.myWhyTableView.register(AnswerCell.nib, forCellReuseIdentifier: AnswerCell.identifier)
        self.myWhyTableView.allowsSelection = true
        self.myWhyTableView.allowsMultipleSelection = true
        self.myWhyTableView.isScrollEnabled = false
        self.myWhyTableView.showsVerticalScrollIndicator = false
        self.myWhyTableView.separatorStyle = .none
        self.myWhyTableView.estimatedRowHeight = UITableView.automaticDimension
        self.myWhyTableView.rowHeight = UITableView.automaticDimension
        
    }
    
    func setupLabels() {
        self.hintView.titleLabel.attributedText = "Set yourself a purpose".localized().styleAll(self.hintView.titleStyle).attributedString
        self.hintView.descriptionLabel.attributedText = "Pick the phrases that mean something to YOU, so we can remind you why you want to succeed".localized().styleAll(self.hintView.descriptionStyle).attributedString
        self.titleLabel.attributedText = "Select up to 5 phrases that light a fire inside you and mean something to you personally".localized().styleAll(self.titleStyle).attributedString
    }
    
    func setupScrollView() {
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
    }
    
    func binding() {
        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()
        
        self.hintView.closePublisher
            .sink(receiveValue: { [weak self] in
                self?.hintView.isHidden = true
                UserDefaults.hideMyWhysHint = true
            }).store(in: &cancellables)
        
        let input = MyWhyVMInput(load: self.load.eraseToAnyPublisher(),
                                 nextAction: nextAction.eraseToAnyPublisher())
        let output = viewModel.transform(input: input)
        
        output
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] state in
                self.render(state)
            }).store(in: &cancellables)
    }
    
    func render(_ state: MyWhyVCState) {
        switch state {
            
        case let .idle(models):
            self.update(with: models)
            self.nextButton.isRequestAction.send(false)
        case .loading:
            self.nextButton.isRequestAction.send(true)
        case let .nextAvailabel(isAvailabel):
            self.nextButton.isEnabled = isAvailabel
        case let .failure(serverError):
            self.nextButton.isUserInteractionEnabled = true
            self.modalAlert(modalStyle: serverError.errorCode)
            self.nextButton.isRequestAction.send(false)
        case let .udpateSelected(count, maxValue):
            self.updateCountLabel(to: count, maxValue: maxValue)
        case .success:
            self.nextButton.isRequestAction.send(false)
        }
    }
    
    func updateCountLabel(to count: Int, maxValue: Int) {
        self.countLabel.text = "\(count)/\(maxValue)"
        self.countLabel.textColor = count == maxValue ? .gray700 : .gray500
        self.countLabel.fadeTransition(0.1)
    }
    
    private func setupNavigationItems() {
        self.navigationController?.navigationBar.topItem?.title = "My why".localized()
        self.navigationController?.visibleViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.countLabel)
        self.navigationController?.visibleViewController?.navigationItem.leftBarButtonItem?.tintColor = .gray700
        self.navigationController?.visibleViewController?.navigationItem.leftBarButtonItem?.isEnabled = true
    }
}

// MARK: - UITableViewDiffableDataSource<Int, MyWhyModel>
private extension MyWhyVC {
    
    func update(with data: [MyWhyModel], animate: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            var snapshot = NSDiffableDataSourceSnapshot<Int, MyWhyModel>()
            snapshot.appendSections([0])
            snapshot.appendItems(data)
            
            self?.dataSource.apply(snapshot, animatingDifferences: animate)
        }
    }
    
    func configDataSource() -> UITableViewDiffableDataSource<Int, MyWhyModel> {
        let dataSource = UITableViewDiffableDataSource<Int, MyWhyModel>(
            tableView: self.myWhyTableView,
            cellProvider: { tableView, indexPath, model in
                let cell = tableView.dequeueReusableCell(withIdentifier: AnswerCell.identifier, for: indexPath) as! AnswerCell
                
                cell.configCell(model: model)
                return cell
            }
        )
        return dataSource
    }
}

// MARK: - IBActions
private extension MyWhyVC {
    
    @IBAction func nextButtonDidTap(_ sender: RequestButton) {
        self.nextAction.send(())
        self.nextButton.isUserInteractionEnabled = false
    }
}
