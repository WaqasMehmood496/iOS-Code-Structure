//
//  CommunityUserCell.swift
//  Evexia
//
//  Created by admin on 23.05.2022.
//

import UIKit
import Kingfisher

class CommunityUserCell: UITableViewCell, CellIdentifiable {

    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with user: CommunityUser) {
        self.userNameLabel.text = user.username
        userAvatar.setImage(url: URL(string: user.avatar.fileUrl ?? ""))
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userAvatar.image = nil
    }
}
