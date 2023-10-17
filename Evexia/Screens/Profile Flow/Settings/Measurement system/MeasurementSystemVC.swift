//
//  MeasurementSystemVC.swift
//  Evexia
//
//  Created by Александр Ковалев on 15.11.2022.
//

import UIKit

final class MeasurementSystemVC: BaseViewController, StoryboardIdentifiable {

    @IBOutlet private weak var tableView: UITableView!
    
    var viewModel: MeasurementSystemVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

private extension MeasurementSystemVC {
    func setupUI() {
        setupTableView()
        title = "Measurement system".localized()
        view.backgroundColor = UIColor(hex: "#F7FAFC")
    }
    
    func setupTableView() {
        tableView.contentInset = .init(top: 16, left: 0, bottom: 16, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.register(MeasurementCell.nib, forCellReuseIdentifier: MeasurementCell.identifier)
        tableView.separatorStyle = .none
    }
}

extension MeasurementSystemVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MeasurementCell.identifier, for: indexPath) as! MeasurementCell
        
        let model = viewModel.dataSource[indexPath.row]
        cell.configCell(model: model)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let model = viewModel.dataSource[indexPath.row]
        
        if model.rawValue == UserDefaults.measurement {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
}
