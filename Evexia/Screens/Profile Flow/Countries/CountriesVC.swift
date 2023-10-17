//
//  CountriesVC.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 29.07.2021.
//

import UIKit
import Combine

final class CountriesVC: BaseViewController, StoryboardIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var countriesTableView: UITableView!
    
    // MARK: - Properties
    var viewModel: CountriesVMType!
    
    private let appear = PassthroughSubject<Void, Never>()
    private let selectCountry = PassthroughSubject<String, Never>()
    private var cancellables: [AnyCancellable] = []
    private var titles: [String] = []
    private var data: [String: [CountryCellModel]] = [:] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.countriesTableView.reloadData()
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind(to: viewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appear.send()
        (self.tabBarController as? TabBarController)?.setTabBarHidden(true, animated: false)
    }
}

// MARK: - Private Methods
private extension CountriesVC {
    
    func bind(to viewModel: CountriesVMType) {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        let input = CountriesVMInput(appear: appear.eraseToAnyPublisher(),
                                     setCountry: self.selectCountry.eraseToAnyPublisher())
        let output = viewModel.transform(input: input)
        output.sink { [unowned self] state in
            self.render(state)
        }.store(in: &cancellables)
    }
    
    func render(_ state: CountriesVCState) {
        switch state {
        case .idle:
            break
        case .loading:
            break
        case .success(let models):
            data = Dictionary(grouping: models, by: { String(describing: $0.country.first!) })
            titles = Array(Set(models.compactMap { String(describing: $0.country.first!) }).sorted())
        case let .failure(error):
            self.modalAlert(modalStyle: error.errorCode)
        }
    }
    
    func setupUI() {
        title = "Countries".localized()
        setupCountriesTableView()
    }
    
    func setupCountriesTableView() {
        countriesTableView.delegate = self
        countriesTableView.dataSource = self
        countriesTableView.register(CountryHeader.nib, forHeaderFooterViewReuseIdentifier: CountryHeader.identifier)
        countriesTableView.separatorInset = UIEdgeInsets(top: 0, left: 16.0, bottom: 0, right: 16.0)
        countriesTableView.separatorColor = .gray300
        countriesTableView.showsVerticalScrollIndicator = false
        if #available(iOS 15.0, *) {
            self.countriesTableView.sectionHeaderTopPadding = 0
        }
    }
    
    func setupBackButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "arrow_left"), style: .plain, target: self, action: #selector(didTapOnNavigationItem(_:)))
    }

    @objc
    func didTapOnNavigationItem(_ sender: Any?) {
        self.viewModel.closeView()
    }
}

// MARK: - TableView Delegate
extension CountriesVC: UITableViewDelegate {

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return titles
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionTitle = titles[indexPath.section]
        let countriesInSection = data[sectionTitle] ?? []
        let country = countriesInSection[indexPath.row]
        self.selectCountry.send(country.country)
    }
}

// MARK: - TableView Data Source
extension CountriesVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitle = titles[section]
        let countriesInSection = data[sectionTitle]!
        return countriesInSection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CountryCell.identifier, for: indexPath) as! CountryCell
        let sectionTitle = titles[indexPath.section]
        let countriesInSection = data[sectionTitle] ?? []
        
        cell.configCell(with: countriesInSection[indexPath.row])
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CountryHeader.identifier) as? CountryHeader else {
            return nil
        }
        header.configHeader(with: titles[section])
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36.0
    }
}
