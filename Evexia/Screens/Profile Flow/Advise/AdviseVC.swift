//
//  AdviseVC.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 17.08.2021.
//

import Combine
import UIKit

final class AdviseVC: BaseViewController, StoryboardIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var adviseTableView: UITableView!
    
    // MARK: - Properties
    var viewModel: AdviseVMType!
    
    private var cancelables: [AnyCancellable] = []
    private let appear = PassthroughSubject<Void, Never>()
    private lazy var tableHeaderView = createHeaderView()
    
    private lazy var dataSource = configureDataSource()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind(to: viewModel)
        appear.send()
        view.showActivityIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        (self.tabBarController as? TabBarController)?.setTabBarHidden(false, animated: true)
    }
}

private extension AdviseVC {
    
    func bind(to viewModel: AdviseVMType) {
        cancelables.forEach { $0.cancel() }
        cancelables.removeAll()
        
        let input = AdviseVMInput(appear: appear.eraseToAnyPublisher())
        let output = viewModel.transform(input: input)
        
        output.sink { [unowned self] state in
            self.render(state)
        }.store(in: &cancelables)
        
        self.tableHeaderView.closeViewPublisher
            .sink(receiveValue: { [weak self] in
                UserDefaults.hideAdwiseAndSupport = true
                self?.adviseTableView.tableHeaderView = nil
            }).store(in: &cancelables)
    }
    
    func render(_ state: AdviseVCState) {
        switch state {
        case .idle(let data):
            update(with: data)
            return
        case .loading:
            return
        case .success:
            return
        case .failure(let error):
            Log.error(error)
            return
        }
    }
    
    func setupUI() {
        title = "Advise and Support".localized()
        setupHint()
        setupAdviseTableView()
        configTableHeaderView()
    }
    
    func setupHint() {
        self.tableHeaderView.titleLabel.text = "Select the appropriate service to access advice & support".localized()
        self.tableHeaderView.isHidden = UserDefaults.hideAdwiseAndSupport
    }
    
    func setupAdviseTableView() {
        adviseTableView.delegate = self
        adviseTableView.dataSource = dataSource
        adviseTableView.tableHeaderView = tableHeaderView
        
        if UserDefaults.hideAdwiseAndSupport {
            var frame = CGRect.zero
            frame.size.height = .leastNormalMagnitude
            adviseTableView.tableHeaderView = UIView(frame: frame)
        }
        
        adviseTableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        adviseTableView.alwaysBounceVertical = false
        adviseTableView.showsVerticalScrollIndicator = false
        
        adviseTableView.layer.masksToBounds = false
        adviseTableView.layer.shadowColor = UIColor.gray400.cgColor
        adviseTableView.layer.shadowOpacity = 0.5
        adviseTableView.layer.shadowRadius = 6
        adviseTableView.layer.shadowOffset = .zero
        
        adviseTableView.register(AdviseContentCell.nib, forCellReuseIdentifier: AdviseContentCell.identifier)
        adviseTableView.register(EmptyFooterView.self, forHeaderFooterViewReuseIdentifier: EmptyFooterView.identifier)

        if #available(iOS 15.0, *) {
            self.adviseTableView.sectionHeaderTopPadding = 0
        }
    }
    
    func configTableHeaderView() {
        tableHeaderView.widthContentViewConstant.constant = adviseTableView.frame.width
        tableHeaderView.frame.size.height = tableHeaderView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        tableHeaderView.layoutIfNeeded()
    }
    
    func update(with data: [[AdviseModel]], animate: Bool = false) {
        view.removeActivityIndicator()
        
        DispatchQueue.main.async { [weak self] in
            var snapshot = NSDiffableDataSourceSnapshot<Int, AdviseModel>()
            
            data.enumerated().forEach { index, elements in
                snapshot.appendSections([index])
                snapshot.appendItems(elements, toSection: index)
            }
            
            self?.dataSource.apply(snapshot, animatingDifferences: animate)
        }
    }
    
    func configureDataSource() -> UITableViewDiffableDataSource<Int, AdviseModel> {
        let dataSource = UITableViewDiffableDataSource<Int, AdviseModel>(
            tableView: adviseTableView, cellProvider: { [weak self] tableView, indexPath, model in
                self?.getCellWithPosition(tableView: tableView, indexPath: indexPath, model: model)
            }
        )
        return dataSource
    }
    
    func applyNavigation(for advise: Advise) {
        Log.info("Navigation \(advise.title)")
    }
    
    func getCellWithPosition(tableView: UITableView, indexPath: IndexPath, model: AdviseModel) -> AdviseContentCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AdviseContentCell.identifier, for: indexPath) as! AdviseContentCell
        let totalRows = tableView.numberOfRows(inSection: indexPath.section)
        
        if totalRows == 1 {
            cell.configure(with: model, position: .single)
        } else if indexPath.row == totalRows - 1 {
            cell.configure(with: model, position: .last)
        } else if indexPath.row == 0 {
            cell.configure(with: model, position: .first)
        } else {
            cell.configure(with: model, position: .middle)
        }
        
        return cell
    }
    
    func createHeaderView() -> AdviseHint {
        let header = AdviseHint(frame: .zero)
        header.isUserInteractionEnabled = true
        return header
    }
}

extension AdviseVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return adviseTableView.tableHeaderView == nil ? 8.0 : 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return adviseTableView.tableHeaderView == nil ? 8.0 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = EmptyFooterView()
        header.backgroundView?.backgroundColor = .clear
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = EmptyFooterView()
        footerView.backgroundView?.backgroundColor = .clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = self.dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        self.viewModel.applyNavigation(for: model)
    }
}
