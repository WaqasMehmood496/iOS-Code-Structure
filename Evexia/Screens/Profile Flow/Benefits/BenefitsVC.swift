//
//  BenefitsVC.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 20.08.2021.
//

import UIKit
import Combine

final class BenefitsVC: BaseViewController, StoryboardIdentifiable {

    // MARK: - IBOutlets
    @IBOutlet private weak var benefitsTableView: UITableView!
    
    // MARK: - Properies
    var viewModel: BenefitsVMType!
    
    private var cancellables: [AnyCancellable] = []
    private var appear = PassthroughSubject<Void, Never>()
    private lazy var dataSource = configureDataSource()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind(to: viewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appear.send()
    }
}

// MARK: - Private Methods
private extension BenefitsVC {
    
    func setupUI() {
        navigationItem.title = "Benefits".localized()
        setupBenefitsTableView()
    }
    
    func setupBenefitsTableView() {
        benefitsTableView.delegate = self
        benefitsTableView.showsVerticalScrollIndicator = false
        benefitsTableView.register(BenefitsCell.nib, forCellReuseIdentifier: BenefitsCell.identifier)
        benefitsTableView.dataSource = dataSource
        benefitsTableView.layer.masksToBounds = false
    }
    
    func configureDataSource() -> UITableViewDiffableDataSource<Int, Benefit> {
        let dataSource = UITableViewDiffableDataSource<Int, Benefit>(
            tableView: benefitsTableView,
            cellProvider: { tableView, indexPath, model in
                let cell = tableView.dequeueReusableCell(withIdentifier: BenefitsCell.identifier, for: indexPath) as! BenefitsCell
                cell.configure(with: model)
                return cell
            }
        )
        return dataSource
    }
    
    func bind(to viewModel: BenefitsVMType) {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        let input = BenefitsVMInput(appear: appear.eraseToAnyPublisher())
        let output = viewModel.transform(input: input)
        output
            .sink { [unowned self] state in
                self.render(state)
            }
            .store(in: &cancellables)
    }
    
    func render(_ state: BenefitsVCState) {
        switch state {
        case .idle:
            break
        case .loading:
            break
        case .success(let benefits):
            update(with: benefits)
        case .failure(let error):
            self.modalAlert(modalStyle: error.errorCode)
        }
    }
    
    func update(with data: [Benefit], animate: Bool = false) {
        guard !data.isEmpty else { return }
        let items = self.dataSource.snapshot().itemIdentifiers

        DispatchQueue.main.async { [weak self] in
            var snapshot = NSDiffableDataSourceSnapshot<Int, Benefit>()
            snapshot.appendSections([0])
            snapshot.appendItems(items + data)
            self?.dataSource.apply(snapshot, animatingDifferences: animate)
        }
    }
}

// MARK: - TableView Delegate
extension BenefitsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let numberOfItems = dataSource.snapshot().numberOfItems
        if indexPath.row >= (numberOfItems - 2) {
            self.appear.send()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let benefit = self.dataSource.itemIdentifier(for: indexPath) else { return }
        self.viewModel.navigate(to: benefit)
    }
}
