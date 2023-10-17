//
//  BenefitsCell.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 25.08.2021.
//

import UIKit
import Kingfisher

final class BenefitsCell: UITableViewCell, CellIdentifiable {

    // MARK: - IBOutlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var bodyImageView: UIImageView!
    @IBOutlet private weak var shadowView: UIView!
    
    override func draw(_ rect: CGRect) {
        shadowView.layer.cornerRadius = 16.0
        avatarImageView.layer.cornerRadius = 16.0
        bodyImageView.layer.cornerRadius = 16.0
        layer.cornerRadius = 16.0
        layer.masksToBounds = false
        layer.shadowColor = UIColor.gray400.cgColor
        layer.shadowRadius = 20
        layer.shadowOpacity = 0.5
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let margins = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        contentView.frame = contentView.frame.inset(by: margins)
    }
    
    func configure(with model: Benefit) {
        self.titleLabel.text = model.partner.title
        self.avatarImageView.kf.setImage(url: model.partner.avatar.fileUrl, sizes: bodyImageView.frame.size)
        self.bodyImageView.kf.setImage(url: model.image.fileUrl, sizes: bodyImageView.frame.size)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.avatarImageView.image = nil
        self.bodyImageView.image = nil
    }
}
