//
//  MyGoalsVC.swift
//  Evexia
//
//  Created by  Artem Klimov on 16.07.2021.
//

import UIKit
import Combine
import Atributika

class MyGoalsVC: BaseViewController, StoryboardIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var setGoalsButton: RequestButton!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var hintView: HintView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var myGoalsTableView: IntrinsicTableView!
    
    var isNeedShow = true
    internal var viewModel: MyGoalsVMType!

    private lazy var dataSource = self.configDataSource()
    private let load = PassthroughSubject<Void, Never>()
    private let nextAction = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
   
    private var paragraphStyle: NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.0
        paragraphStyle.alignment = .center
        return paragraphStyle
    }
    
    var titleStyle: Style {
        return Style()
            .foregroundColor(.gray900, .normal)
            .font(UIFont(name: "NunitoSans-Bold", size: 18.0)!)
            .custom(self.paragraphStyle, forAttributedKey: NSAttributedString.Key.paragraphStyle)
    }
    
    // MARK: - VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.binding()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationItems()
        if isNeedShow {
            load.send()
            self.isNeedShow = false
        }
        setGoalsButton.isUserInteractionEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func setupUI() {
        self.setupTableView()
        self.setupLabels()
        self.setupScrollView()
        self.hintView.imageView.image = UIImage(named: "trophy")
        self.hintView.isHidden = UserDefaults.hideMyGoalsHint
    }
    
    private func setupTableView() {
        self.myGoalsTableView.dataSource = self.dataSource
        self.myGoalsTableView.delegate = self
        self.myGoalsTableView.register(MyGoalCell.nib, forCellReuseIdentifier: MyGoalCell.identifier)
        self.myGoalsTableView.allowsSelection = true
        self.myGoalsTableView.allowsMultipleSelection = true
        self.myGoalsTableView.showsVerticalScrollIndicator = false
        self.myGoalsTableView.isScrollEnabled = false
        self.myGoalsTableView.separatorStyle = .none
        self.myGoalsTableView.register(MyGoalsSectionHeader.nib, forHeaderFooterViewReuseIdentifier: MyGoalsSectionHeader.identifier)
        self.myGoalsTableView.estimatedRowHeight = UITableView.automaticDimension
        self.myGoalsTableView.rowHeight = UITableView.automaticDimension
        
        if #available(iOS 15.0, *) {
            self.myGoalsTableView.sectionHeaderTopPadding = 0
        }
    }
    
    private func setupLabels() {
        self.hintView.titleLabel.attributedText = "Define your goals".localized().styleAll(self.hintView.titleStyle).attributedString
        
        self.hintView.descriptionLabel.attributedText = "Tailor your plan further - with tasks you’ll enjoy - based on your selections. ".localized().styleAll(self.hintView.descriptionStyle).attributedString
        
        self.titleLabel.attributedText = "What works for you?".localized().styleAll(self.titleStyle).attributedString
        
        self.descriptionLabel.text = "What content would you like to see in your library".localized()
    }
    
    private func setupScrollView() {
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
    }
    
    private func binding() {
    
        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()
        
        self.hintView.closePublisher
            .sink(receiveValue: { [weak self] in
                self?.hintView.isHidden = true
                UserDefaults.hideMyGoalsHint = true
            }).store(in: &cancellables)
        
        let input = MyGoalsVMInput(load: self.load.eraseToAnyPublisher(),
                                   nextAction: nextAction.eraseToAnyPublisher())
        let output = viewModel.transform(input: input)
        
        output
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] state in
                self.render(state)
            }).store(in: &cancellables)
        
        viewModel.reconfigCellModel
            .sink(receiveValue: { [weak self] models in
                guard let self = self else { return }
                self.update(with: models)
            }).store(in: &cancellables)
    }
    
    func render(_ state: MyGoalsVCState) {
        switch state {
        case let .idle(sections):
            self.update(with: sections)
            self.setGoalsButton.isRequestAction.send(false)
        case .loading:
            self.setGoalsButton.isRequestAction.send(true)
        case let .nextAvailabel(isAvailabel):
            self.setGoalsButton.isEnabled = isAvailabel
        case let .failure(serverError):
            self.modalAlert(modalStyle: serverError.errorCode)
            self.setGoalsButton.isRequestAction.send(false)
        case .success:
            self.setGoalsButton.isRequestAction.send(false)
        }
    }
    
    private func setupNavigationItems() {
        self.navigationController?.navigationBar.topItem?.title = "My goals".localized()
        self.navigationController?.visibleViewController?.navigationItem.leftBarButtonItem?.tintColor = .gray700
        self.navigationController?.visibleViewController?.navigationItem.leftBarButtonItem?.isEnabled = true
    }
}

// MARK: - IBAction
extension MyGoalsVC {
    @IBAction func setMyGoals(_ sender: RequestButton) {
        self.nextAction.send(())
        setGoalsButton.isUserInteractionEnabled = false
    }
}

// MARK: - MyGoalsVC: UITableViewDelegate
extension MyGoalsVC: UITableViewDelegate {
    
    func update(with sections: [FocusSection], animate: Bool = false) {
        
        DispatchQueue.main.async { [weak self] in
            var snapshot = MyGoalsSnaphot()
            let sordetSection = sections.sorted(by: { $0.focus < $1.focus })
            snapshot.appendSections(sordetSection)
            sordetSection.forEach { section in
                snapshot.appendItems(section.goals, toSection: section)
            }
            
            if #available(iOS 15.0, *) {
                self?.dataSource.applySnapshotUsingReloadData(snapshot)
            } else {
                self?.dataSource.apply(snapshot, animatingDifferences: animate)
            }
        }
    }
    
    private func configDataSource() -> MyGoalsDataSource {
        let dataSource = MyGoalsDataSource(tableView: self.myGoalsTableView, cellProvider: { tableView, indexPath, model in
            let cell = tableView.dequeueReusableCell(withIdentifier: MyGoalCell.identifier, for: indexPath) as! MyGoalCell
            cell.configCell(model: model)
            return cell
        })
        
        return dataSource
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: MyGoalsSectionHeader.identifier) as? MyGoalsSectionHeader else {
            return nil
        }
        let section = self.dataSource.snapshot().sectionIdentifiers[section]
        header.configHeader(with: section.focus)
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UITableViewHeaderFooterView()
        let backgroundView = UIView(frame: footer.bounds)
        backgroundView.backgroundColor = .clear
        footer.backgroundView = backgroundView
        return footer
    }
}
