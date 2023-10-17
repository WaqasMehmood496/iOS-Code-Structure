//
//  DevicesCell.swift
//  Evexia
//
//  Created by  Artem Klimov on 18.08.2021.
//

import UIKit
import Combine

class DevicesCell: UITableViewCell, CellIdentifiable {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deviceImageView: UIImageView!
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var deviceSwitch: UISwitch!
    @IBOutlet weak var syncOtherLabel: UILabel!
    
    @IBAction func syncOtherButtonDidTap(_ sender: Any) {
        
    }
    
    var cancellables = Set<AnyCancellable>()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.deviceSwitch.layer.cornerRadius = self.deviceSwitch.frame.height / 2.0
        self.deviceSwitch.clipsToBounds = true
        
        self.shadowView.layer.cornerRadius = 16.0
        self.shadowView.layer.masksToBounds = false
        self.shadowView.layer.shadowOffset = .zero
        self.shadowView.layer.shadowColor = UIColor.gray400.cgColor
        self.shadowView.layer.shadowRadius = 8.0
        self.shadowView.layer.shadowOpacity = 0.5
        self.shadowView.layer.shadowPath = UIBezierPath(rect: shadowView.bounds).cgPath
        
        self.deviceImageView.layer.cornerRadius = 16.0
        self.deviceImageView.layer.masksToBounds = false
        self.deviceImageView.layer.shadowOffset = .zero
        self.deviceImageView.layer.shadowColor = UIColor.gray400.cgColor
        self.deviceImageView.layer.shadowRadius = 8.0
        self.deviceImageView.layer.shadowOpacity = 0.5
        self.deviceImageView.layer.shadowPath = UIBezierPath(rect: deviceImageView.bounds).cgPath
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.deviceSwitch.isOn = UserDefaults.appleHealthSync ?? false

        self.deviceSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }
    
    func configCell(with model: ProfileCellContentType) {
        
    }
    
    @objc
    func switchValueChanged(sender: UISwitch) {
        if sender.isOn {
            HealthKitSetupAssistant.authorizeHealthKit { success, _ in
                if success {
                    UserDefaults.appleHealthSync = true
                } else {
                    UserDefaults.appleHealthSync = false
                }
            }
        } else {
            UserDefaults.stepsCount = nil
            UserDefaults.appleHealthSync = false
        }
    }
}
