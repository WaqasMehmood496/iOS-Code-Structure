//
//  PDCategoryDetailsVC.swift
//  Evexia Staging
//
//  Created by Oleg Pogosian on 09.12.2021.
//

import UIKit
import Combine
import Reachability

class PDCategoryDetailsVC: BaseViewController, StoryboardIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var noConnectionImage: UIImageView!
    @IBOutlet weak var emptyDataView: UIView!
    
    // MARK: - Properties
    var viewModel: PDCategoryDetailsVMType!
    private var cancelables: [AnyCancellable] = []
    private var appear = PassthroughSubject<Void, Never>()
    private lazy var dataSource = configurateDataSource()
    private let reachability = try! Reachability()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - UI
    private func setupUI() {
        title = viewModel.screenTitle
        tableView.isHidden = true
        checkInternetState()
        binding()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.register(PDCategoryDetailsCell.nib, forCellReuseIdentifier: PDCategoryDetailsCell.identifier)
        tableView.dropShadow(radius: 8, xOffset: 0, yOffset: 0, shadowOpacity: 1, shadowColor: UIColor.gray400.withAlphaComponent(0.5))
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 10, right: 0)
    }
    
    func checkInternetState() {
        // connected observer
        self.reachability.whenReachable = { [weak self] _ in
            guard let self = self else { return }
            
            self.noConnectionImage.isHidden = true
            self.tableView.isHidden = false
        }
        
        self.reachability.whenUnreachable = { [weak self] _ in
            
            guard let self = self else { return }
            
            self.modalAlert(modalStyle: ServerError(errorCode: .networkConnectionError).errorCode, completion: { })
            self.noConnectionImage.isHidden = false
            self.tableView.isHidden = true
        }
        
        // start reachability observer
        do {
            try self.reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    private func configurateDataSource() -> UITableViewDiffableDataSource<Int, PDCategoryDetailsModel> {
        let dataSource = UITableViewDiffableDataSource<Int, PDCategoryDetailsModel>(
            tableView: self.tableView,
            cellProvider: { tableView, indexPath, model in
                let cell = tableView.dequeueReusableCell(withIdentifier: PDCategoryDetailsCell.identifier, for: indexPath) as! PDCategoryDetailsCell
                cell.configure(with: model)
                cell.changeFavoritePublisher
                    .sink(receiveValue: { [weak self] model in
                        Vibration.selection.vibrate()
                        self?.viewModel.changeFavorite(for: model)
                    })
                    .store(in: &cell.cancellables)
                return cell
            }
        )
        return dataSource
    }
    
    func update(with conten: [PDCategoryDetailsModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, PDCategoryDetailsModel>()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(conten)
        
        if #available(iOS 15.0, *) {
            self.dataSource.applySnapshotUsingReloadData(snapshot)
        } else {
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
        
        if snapshot.numberOfItems == 0 {
            tableView.isHidden = true
            emptyDataView.isHidden = false
        } else {
            tableView.isHidden = false
            emptyDataView.isHidden = true
        }
        
    }
    
    private func binding() {
        self.viewModel.content
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] content in
                self?.update(with: content)
            }).store(in: &self.cancelables)
    }
    
}

extension PDCategoryDetailsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let numberOfItems = self.viewModel.content.value.count
        if indexPath.row >= (numberOfItems - 2) {
            self.viewModel.getMoreContent()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = dataSource.itemIdentifier(for: indexPath) else { return }
        
        self.viewModel.applyNavigation(for: model)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.frame.size.height = 16
        headerView.backgroundColor = .white
        headerView.layer.cornerRadius = 10
        headerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.frame.size.height = 16
        footerView.backgroundColor = .white
        footerView.layer.cornerRadius = 10
        footerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16
    }
    
}
