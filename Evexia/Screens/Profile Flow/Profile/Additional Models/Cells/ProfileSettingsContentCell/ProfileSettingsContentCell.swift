//
//  ProfileBenefitsCell.swift
//  Evexia
//
//  Created by  Artem Klimov on 18.08.2021.
//

import UIKit
import Combine

class ProfileSettingsContentCell: UITableViewCell, CellIdentifiable {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var settingsTableView: UITableView!
    
    lazy var dataSource = self.configDataSource()
    var settingsNavigationPublisher = PassthroughSubject<ProfileSettings, Never>()
    var cancellables = Set<AnyCancellable>()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.setupUI()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.shadowView.layer.cornerRadius = 16.0
        self.shadowView.layer.masksToBounds = false
        self.shadowView.layer.shadowColor = UIColor.gray400.cgColor
        self.shadowView.layer.shadowRadius = 8.0
        self.shadowView.layer.shadowOpacity = 0.5
        self.shadowView.layer.shadowOffset = .zero
        self.shadowView.layer.shadowPath = UIBezierPath(rect: shadowView.bounds).cgPath
        self.settingsTableView.layer.cornerRadius = 16.0
    }

    private func setupUI() {
        self.settingsTableView.delegate = self
        self.settingsTableView.rowHeight = 56.0
        self.settingsTableView.register(ProfileSettingCell.nib, forCellReuseIdentifier: ProfileSettingCell.identifier)
        self.settingsTableView.register(EmptyFooterView.self, forHeaderFooterViewReuseIdentifier: EmptyFooterView.identifier)
        
        self.settingsTableView.separatorInset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
        self.settingsTableView.separatorColor = .gray300
        
        if #available(iOS 15.0, *) {
            self.settingsTableView.sectionHeaderTopPadding = 0
        }

    }
    
    func configCell(with content: [ProfileSettings]) {
        self.update(with: content)
    }
    
    private func update(with data: [ProfileSettings]) {
        DispatchQueue.main.async { [weak self] in
            var snapshot = NSDiffableDataSourceSnapshot<Int, ProfileSettings>()
            snapshot.appendSections([0])
            snapshot.appendItems(data)
            
            self?.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    func configDataSource() -> UITableViewDiffableDataSource<Int, ProfileSettings> {
        let dataSource = UITableViewDiffableDataSource<Int, ProfileSettings>(
            tableView: self.settingsTableView,
            cellProvider: { tableView, indexPath, model in
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileSettingCell.identifier, for: indexPath) as! ProfileSettingCell
                cell.configCell(with: model)
                return cell
            }
        )
        return dataSource
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()
    }
}

extension ProfileSettingsContentCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = self.dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        self.settingsNavigationPublisher.send(model)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return EmptyFooterView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return EmptyFooterView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8.0
    }
}
