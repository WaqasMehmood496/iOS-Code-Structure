//
//  PersonalDevelopmentVC.swift
//  Evexia Staging
//
//  Created by Oleg Pogosian on 07.12.2021.
//

import UIKit
import Combine
import Reachability

class PersonalDevelopmentVC: BaseViewController, StoryboardIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var noConnectionImage: UIImageView!
    @IBOutlet weak var emptyDataView: UIView!
    
    // MARK: - Properties
    var viewModel: PersonalDevelopmentVMType!
    private var cancelables: [AnyCancellable] = []
    private let appear = PassthroughSubject<Void, Never>()
    
    private lazy var dataSource = configurateDataSource()
    private let reachability = try! Reachability()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind(to: viewModel)
        appear.send()
    }
    
    // MARK: - UI
    private func setupUI() {
        title = "Personal Development"
        self.tableView.isHidden = true
        setupTableView()
        view.showActivityIndicator()
        checkInternetState()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.register(PersonalDevelopmentCell.nib, forCellReuseIdentifier: PersonalDevelopmentCell.identifier)
        
        tableView.dropShadow(radius: 10, xOffset: 0, yOffset: 0, shadowOpacity: 1, shadowColor: UIColor.gray400.withAlphaComponent(0.5))
        
        tableView.contentInset = UIEdgeInsets(top: 14, left: 0, bottom: 10, right: 0)
    }
    
    private func configurateDataSource() -> UITableViewDiffableDataSource<Int, PersonalDevCategoryElement> {
        let dataSource = UITableViewDiffableDataSource<Int, PersonalDevCategoryElement>(
            tableView: tableView, cellProvider: { [weak self] _, indexPath, model in
                self?.configurateCell(model: model, indexPath: indexPath)
            }
        )
        return dataSource
    }
    
    private func configurateCell(model: PersonalDevCategoryElement, indexPath: IndexPath) -> PersonalDevelopmentCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PersonalDevelopmentCell.identifier, for: indexPath) as! PersonalDevelopmentCell
        cell.configure(with: model.title, hideSeparator: model.title == "Favourites" ? true : false)
        return cell
    }
    
    private func bind(to viewModel: PersonalDevelopmentVMType) {
        cancelables.forEach { $0.cancel() }
        cancelables.removeAll()
        
        let input = PersonalDevelopmentVMInput(appear: appear.eraseToAnyPublisher())
        let output = viewModel.transform(input: input)
        
        output.sink { [unowned self] state in
            self.render(state)
        }.store(in: &cancelables)
        
    }
    
    private func render(_ state: PersonalDevelopmentVCState) {
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
    
    private func update(with data: PersonalDevCategory, animate: Bool = false) {
        view.removeActivityIndicator()
        var data = data
        data.append(PersonalDevCategoryElement(title: "Favourites", value: -1))
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            var snapshot = NSDiffableDataSourceSnapshot<Int, PersonalDevCategoryElement>()
            snapshot.appendSections([0])
            snapshot.appendItems(data)
            self.dataSource.apply(snapshot, animatingDifferences: animate)
            
            if snapshot.numberOfItems == 1 {
                self.tableView.isHidden = true
                self.emptyDataView.isHidden = false
            } else {
                self.tableView.isHidden = false
                self.emptyDataView.isHidden = true
            }
        }
    }
    
    func checkInternetState() {
        // connected observer
        self.reachability.whenReachable = { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.noConnectionImage.isHidden = true
                self.tableView.isHidden = false
            }
        }
        
        self.reachability.whenUnreachable = { [weak self] _ in
            
            guard let self = self else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.modalAlert(modalStyle: ServerError(errorCode: .networkConnectionError).errorCode, completion: { })
                
                self.noConnectionImage.isHidden = false
                self.emptyDataView.isHidden = true
                self.tableView.isHidden = true
                self.view.removeActivityIndicator()
            }
        }
        
        // start reachability observer
        do {
            try self.reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
}

extension PersonalDevelopmentVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let model = self.dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        viewModel.applyNavigation(id: model.value, title: model.title)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.frame.size.height = 16
        headerView.backgroundColor = .white
        headerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        headerView.layer.cornerRadius = 10
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.frame.size.height = 16
        footerView.backgroundColor = .white
        footerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        footerView.layer.cornerRadius = 10
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16
    }
    
}
