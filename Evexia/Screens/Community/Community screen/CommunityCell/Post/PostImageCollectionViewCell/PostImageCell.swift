//
//  PostImageCell.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 05.09.2021.
//

import UIKit
import Kingfisher

class PostImageCell: UICollectionViewCell, CellIdentifiable {
    
    @IBOutlet weak var postImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func config(with model: String) {
        showActivityIndicator()
        postImageView.kf.setImage(url: model, sizes: postImageView.frame.size, resize: false, placeholder: nil, completionHandler: { [weak self] _ in
            self?.removeActivityIndicator()

        })
    }
    
    private func setupUI() {
        postImageView.layer.cornerRadius = 12
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postImageView.image = nil
        postImageView.kf.cancelDownloadTask()
    }
}
