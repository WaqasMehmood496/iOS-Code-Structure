//
//  LikesSharedCell.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 09.09.2021.
//

import UIKit

// MARK: - LikesSharedCell
class LikesSharedCell: UITableViewCell, CellIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameUserLabel: UILabel!
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupUI()
    }
    
    // MARK: - Methods
    @discardableResult
    func config(with model: LikeAndShares) -> LikesSharedCell {
        let url = URL(string: model.avatar?.fileUrl ?? "")
        avatarImageView.setImage(url: url)
        nameUserLabel.text = model.firstName + " " + model.lastName
        
        return self
    }
    
    func setupUI() {
        avatarImageView.layer.cornerRadius = 12
        
        nameUserLabel.font = UIFont(name: "NunitoSans-Bold", size: 16.0)!
        nameUserLabel.textColor = .gray900
        
    }
}
