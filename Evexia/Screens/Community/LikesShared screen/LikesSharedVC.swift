//
//  LikesSharedVC.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 09.09.2021.
//

import UIKit
import Combine

// MARK: - LikesSharedVC
class LikesSharedVC: BaseViewController, StoryboardIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var viewModel: LikesSharedVMType!
    
    let appear = PassthroughSubject<LikesSharedStartVCType, Never>()
    var cancellable = Set<AnyCancellable>()
    
    private lazy var dataSource = configDataSource()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind(with: viewModel)
        appear.send(viewModel.startVCType)
    }
    
    // MARK: - Methods
    func bind(with: LikesSharedVMType) {
        cancellable.forEach { $0.cancel() }
        cancellable.removeAll()
        
        let input = LikesSharedVMInput(appear: appear.eraseToAnyPublisher())
        
        let output = viewModel.transform(input: input)
        
        output.sink { [weak self] state in
            self?.render(state: state)
        }.store(in: &cancellable)
    }
    
    func render(state: LikesSharedVCState) {
        switch state {
        case let .failure(error):
            modalAlert(modalStyle: error.errorCode)
        case let .success(list):
            navTitleLabel.text = viewModel.startVCType == .likes ? "\(list.count) Likes" : "\(list.count) Shares"
            update(with: list)
        default: break
        }
    }
    
    // MARK: - Action
    @IBAction func closeVC(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - Private Extension
private extension LikesSharedVC {
    func setupUI() {
        
        view.layer.cornerRadius = 30
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        tableView.register(LikesSharedCell.nib, forCellReuseIdentifier: LikesSharedCell.identifier)
        tableView.register(EmptyFooterView.self, forHeaderFooterViewReuseIdentifier: EmptyFooterView.identifier)
    }
}

// MARK: - UITableViewDelegate & DataSource
extension LikesSharedVC: UITableViewDelegate {
    func update(with model: [LikeAndShares], animated: Bool = false) {
        var snapShot = NSDiffableDataSourceSnapshot<Int, LikeAndShares>()
        
        snapShot.appendSections([0])
        snapShot.appendItems(model)
        
        dataSource.apply(snapShot)
    }
    
    func configDataSource() -> UITableViewDiffableDataSource<Int, LikeAndShares> {
        let dataSource = UITableViewDiffableDataSource<Int, LikeAndShares>(
            tableView: tableView) { tableView, _, model in
            return (tableView.dequeueReusableCell(withIdentifier: LikesSharedCell.identifier) as? LikesSharedCell)?
                .config(with: model)
        }
        
        return dataSource
    }
}

// MARK: TableViewHeader & Footer
extension LikesSharedVC {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12.0
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12.0
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
}
