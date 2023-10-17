//
//  MyImpactVC.swift
//  Evexia
//
//  Created by Oleksand Kovalov on 15.02.2022.
//  
//

import UIKit
import Combine

// MARK: - MyImpactVC
class MyImpactVC: BaseViewController, StoryboardIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Properties
    var viewModel: MyImpactVM!
    
    private let appear = PassthroughSubject<Void, Never>()
    private var cancellables: [AnyCancellable] = []
    
    private lazy var dataSource = configureDataSource()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        showSavePlanetPopUp()
        binding()
    }
}

// MARK: - Private Methods
private extension MyImpactVC {
    func setupUI() {
        setupTableView()
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        navigationItem.title = "My Impact".localized()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.alwaysBounceVertical = false
        tableView.dataSource = dataSource
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
    
        tableView.register(MyImpactCell.nib, forCellReuseIdentifier: MyImpactCell.identifier)
        
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0
        }
    }
    
    func showSavePlanetPopUp() {
        if !UserDefaults.isShowSavePlanetPopUp {
            UserDefaults.isShowSavePlanetPopUp = true
            showAchievementPopUp(type: .saveThePlanet) { }
        }
    }
}

// MARK: - Bind
extension MyImpactVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Explore Your Impact".localized()
        label.font = UIFont(name: "NunitoSans-Bold", size: 20.0)!
        label.textColor = .darkBlueNew
        return label
    }
    
    private func binding() {
        self.viewModel.dataSource
            .sink(receiveValue: { [weak self] data in
                self?.update(with: data)
            }).store(in: &cancellables)
    }
    
    private func update(with data: [CarboneModel], animated: Bool = false) {
    
        var snapshot = NSDiffableDataSourceSnapshot<Int, CarboneModel>()
        
        snapshot.appendSections([0])
        snapshot.appendItems(data)
        
        DispatchQueue.main.async { [weak self] in
            if #available(iOS 15.0, *) {
                self?.dataSource.applySnapshotUsingReloadData(snapshot)
            } else {
                self?.dataSource.apply(snapshot, animatingDifferences: animated)
            }
            self?.view.removeActivityIndicator()
        }
    }
    
    private func configureDataSource() -> UITableViewDiffableDataSource<Int, CarboneModel> {
        let dataSource = UITableViewDiffableDataSource<Int, CarboneModel>(tableView: tableView) { tableView, _, model in
            (tableView.dequeueReusableCell(withIdentifier: MyImpactCell.identifier) as? MyImpactCell)?.config(with: model)
        }
        
        return dataSource
    }
}
