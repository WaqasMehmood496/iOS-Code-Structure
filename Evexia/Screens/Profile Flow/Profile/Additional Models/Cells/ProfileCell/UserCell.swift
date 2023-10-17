//
//  UserCell.swift
//  Evexia
//
//  Created by  Artem Klimov on 17.08.2021.
//

import UIKit
import Kingfisher

class UserCell: UITableViewCell, CellIdentifiable {

    @IBOutlet private weak var avatarBackgroundView: UIView!
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var shadowBackgroundView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func draw(_ rect: CGRect) {
        self.shadowBackgroundView.layer.cornerRadius = 16.0
        self.shadowBackgroundView.layer.masksToBounds = false
        self.shadowBackgroundView.layer.shadowColor = UIColor.gray400.cgColor
        self.shadowBackgroundView.layer.shadowRadius = 8.0
        self.shadowBackgroundView.layer.shadowOpacity = 0.5
        self.shadowBackgroundView.layer.shadowOffset = .zero
        self.shadowBackgroundView.layer.shadowPath = UIBezierPath(rect: shadowBackgroundView.bounds).cgPath

        self.avatarImageView.layer.cornerRadius = 40.0
        self.avatarBackgroundView.layer.cornerRadius = 44.0
        self.avatarImageView.layer.masksToBounds = true
        self.avatarBackgroundView.layer.shadowColor = UIColor.gray400.cgColor
        self.avatarBackgroundView.layer.shadowRadius = 4
        self.avatarBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.avatarBackgroundView.layer.shadowOpacity = 0.5

    }
    
    func configCell(with model: User?) {
        guard let user = model else { return }
        self.setAvatar(url: user.avatar?.fileUrl)
        self.nameLabel.text = user.firstName + " " + user.lastName
        self.emailLabel.text = user.email
        self.locationLabel.text = user.country
    }
    
    private func setAvatar(url: String?) {
        let urlString = url ?? ""
        let url = URL(string: urlString)
        self.avatarImageView.kf.setImage(with: url, placeholder: UIImage(named: "avatar")) { [weak self] completion in
            switch completion {
            case .failure:
                self?.avatarImageView.contentMode = .center
            case .success:
                self?.avatarImageView.contentMode = .scaleAspectFill
            }
        }
    }
}
