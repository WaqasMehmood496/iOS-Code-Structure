//
//  SettingCell.swift
//  Evexia
//
//  Created by  Artem Klimov on 09.08.2021.
//

import UIKit
import Combine

class SettingCell: UITableViewCell, CellIdentifiable {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchControl: UISwitch!
    @IBOutlet weak var disclouserView: UIImageView!
    
    var switchChangedPublisher = PassthroughSubject<Bool, Never>()
    private var settingType: Settings!
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.switchControl.layer.cornerRadius = switchControl.frame.height / 2.0
        self.switchControl.clipsToBounds = true
        
        UserDefaults.$biometricСonfirmationisOn
            .sink { [weak self] isOn in
                guard let isOn = isOn else {
                    return
                }
                guard self?.settingType == .faceTouchId else {
                    return
                }
                self?.switchControl.isOn = isOn
            }.store(in: &cancellables)
    }
    
    func configCell(for setting: Settings) {
        self.settingType = setting
        self.titleLabel.text = setting.title
        self.titleLabel.textColor = setting.accent
        
        self.configUI(for: setting)
    }
    
    private func configUI(for setting: Settings) {
        switch setting {
        case .logout, .delete, .passwordCahnge:
            self.disclouserView.isHidden = true
            self.switchControl.isHidden = true
        case .darkMode, .gamefication, .faceTouchId:
            if setting == .gamefication {
                self.switchControl.isOn = UserDefaults.isShowAchieve
                self.switchControl.onTintColor = UIColor(named: "connectNew")
            } else if setting == .faceTouchId {
                self.switchControl.isOn = KeychainProvider().getBiometricSettings()?.access == true
                self.switchControl.onTintColor = UIColor(named: "connectNew")
            }
            self.switchControl.isHidden = false
            self.disclouserView.isHidden = true
        default:
            self.switchControl.isHidden = true
        }
    }
    
    @IBAction func switchChangedAction(_ sender: UISwitch) {
        if self.settingType == .gamefication || self.settingType == .faceTouchId {
            switchChangedPublisher.send(sender.isOn)
        }
    }
}
