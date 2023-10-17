//
//  SettingsContentCell.swift
//  Evexia
//
//  Created by  Artem Klimov on 09.08.2021.
//

import UIKit
import Combine

class SettingsContentCell: UITableViewCell, CellIdentifiable, UITableViewDelegate {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var settingsTableView: UITableView!
    
    var settingsNavigationPublisher = PassthroughSubject<Settings, Never>()
    var switchPublisher = PassthroughSubject<(Settings, Bool), Never>()
    var cancellables = Set<AnyCancellable>()
    
    private lazy var dataSource = self.configDataSource()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    func configCell(with models: [Settings]) {
        self.update(with: models)
    }
    
    override func draw(_ rect: CGRect) {
        self.shadowView.layer.cornerRadius = 16.0
        self.settingsTableView.layer.cornerRadius = 16.0
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.gray400.cgColor
        self.layer.shadowRadius = 20
        self.layer.shadowOpacity = 0.5
    }
    
    private func setupUI() {
        self.settingsTableView.delegate = self
        
        self.selectionStyle = .none
        self.settingsTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.settingsTableView.rowHeight = 56.0
        
        self.settingsTableView.register(SettingCell.nib, forCellReuseIdentifier: SettingCell.identifier)
        self.settingsTableView.register(EmptyFooterView.self, forHeaderFooterViewReuseIdentifier: EmptyFooterView.identifier)
        self.settingsTableView.register(MyAvailabilityHeaderView.self, forHeaderFooterViewReuseIdentifier: MyAvailabilityHeaderView.identifier)
        if #available(iOS 15.0, *) {
            self.settingsTableView.sectionHeaderTopPadding = 0
        }
    }
    
    func update(with data: [Settings], animate: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            var snapshot = NSDiffableDataSourceSnapshot<Int, Settings>()
            snapshot.appendSections([0])
            snapshot.appendItems(data)
            
            self?.dataSource.apply(snapshot, animatingDifferences: animate)
        }
    }
    
    func configDataSource() -> UITableViewDiffableDataSource<Int, Settings> {
        let dataSource = UITableViewDiffableDataSource<Int, Settings>(
            tableView: self.settingsTableView,
            cellProvider: { tableView, indexPath, model in
                let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.identifier, for: indexPath) as! SettingCell
                cell.configCell(for: model)
                
                if model == .gamefication || model == .faceTouchId {
                    cell.switchChangedPublisher.sink(receiveValue: { [weak self] isOn in
                        guard let self = self else { return }
                        
                        self.switchPublisher.send((model, isOn))
                    }).store(in: &self.cancellables)
                    return cell
                }
                
                return cell
            }
        )
        return dataSource
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return MyAvailabilityHeaderView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return EmptyFooterView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = self.dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        self.settingsNavigationPublisher.send(model)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()
    }
}
