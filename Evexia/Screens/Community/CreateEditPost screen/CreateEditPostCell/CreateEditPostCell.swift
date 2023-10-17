//
//  CreateEditPostCell.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 07.09.2021.
//

import UIKit
import Combine

// MARK: - CreateEditPostCell
class CreateEditPostCell: UICollectionViewCell, CellIdentifiable {

    // MARK: - IBOutlets
    @IBOutlet weak var postImageView: UIImageView!
    
    // MARK: - Properties
    var cancellable: Set<AnyCancellable> = []
    let deleteImagePublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellable.forEach { $0.cancel() }
        cancellable.removeAll()
    }
    
    // MARK: - Methods
    @discardableResult
    func config(with image: UIImage?, urlImage: String?) -> CreateEditPostCell {
        if let url = urlImage {
            let url = URL(string: url)
            postImageView.setImage(url: url)
            return self
        }
        
        postImageView.image = image
        return self
    }

    private func setupUI() {
        postImageView.layer.cornerRadius = 12
    }
    
    // MARK: - Action
    @IBAction func deleteImage(_ sender: UIButton) {
        deleteImagePublisher.send()
    }
}
