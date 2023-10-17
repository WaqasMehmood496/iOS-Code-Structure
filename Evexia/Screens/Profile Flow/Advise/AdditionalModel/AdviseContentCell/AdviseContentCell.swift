//
//  AdviseContentCell.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 18.08.2021.
//

import UIKit
import Combine

class AdviseContentCell: UITableViewCell, CellIdentifiable, UITableViewDelegate {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var adviseTableView: UITableView!
    
    var cancellables = Set<AnyCancellable>()
    var adviseNavigationSubject = PassthroughSubject<Advise, Never>()
    
    private lazy var dataSource = configureDataSource()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func draw(_ rect: CGRect) {
        shadowView.layer.cornerRadius = 16.0
        adviseTableView.layer.cornerRadius = 16.0
        layer.masksToBounds = false
        layer.shadowColor = UIColor.gray400.cgColor
        layer.shadowRadius = 20
        layer.shadowOpacity = 0.5
        selectionStyle = .none
    }
    
    func configure(with models: [[Advise]]) {
        update(with: models)
    }
    
    private func setupUI() {
        adviseTableView.delegate = self
        adviseTableView.register(AdviseCell.nib, forCellReuseIdentifier: AdviseCell.identifier)
        adviseTableView.register(EmptyFooterView.self, forHeaderFooterViewReuseIdentifier: EmptyFooterView.identifier)
        adviseTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func update(with models: [[Advise]], animate: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            var snapshot = NSDiffableDataSourceSnapshot<Int, Advise>()
            snapshot.appendSections([0, 1])
            
            [0, 1].forEach { section in
                snapshot.appendItems(models[section], toSection: section)
            }
            self?.dataSource.apply(snapshot, animatingDifferences: animate)
        }
    }
    
    func configureDataSource() -> UITableViewDiffableDataSource<Int, Advise> {
        return UITableViewDiffableDataSource<Int, Advise>(
            tableView: adviseTableView,
            cellProvider: { tableView, indexPath, model in
                let cell = tableView.dequeueReusableCell(withIdentifier: AdviseCell.identifier, for: indexPath) as! AdviseCell
                cell.configure(with: model)
                return cell
            }
        )
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return EmptyFooterView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return EmptyFooterView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        adviseNavigationSubject.send(model)
    }
}
