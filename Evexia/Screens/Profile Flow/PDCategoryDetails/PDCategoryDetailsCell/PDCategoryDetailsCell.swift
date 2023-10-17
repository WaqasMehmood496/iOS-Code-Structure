//
//  PDCategoryDetailsTableViewCell.swift
//  Evexia Staging
//
//  Created by Oleg Pogosian on 09.12.2021.
//

import UIKit
import Combine
import Kingfisher

class PDCategoryDetailsCell: UITableViewCell, CellIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    
    // MARK: - Properties
    var changeFavoritePublisher = PassthroughSubject<PDCategoryDetailsModel, Never>()
    var model: PDCategoryDetailsModel?
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        categoryImageView.layer.cornerRadius = 5
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()
    }
    
    // MARK: - UI
    func configure(with model: PDCategoryDetailsModel) {
        
        categoryNameLabel.text = model.title
        self.model = model
        setFavoriteButton(isFavorite: model.isFavorite ?? false)
        
        let url = URL(string: model.videoPlaceholder.fileURL)!
        let resource = ImageResource(downloadURL: url)

        categoryImageView.kf.setImage(with: resource)
    }
    
    private func setFavoriteButton(isFavorite: Bool) {
        favouriteButton.isSelected = isFavorite
    }
    
    // MARK: - IBActions
    @IBAction func favouriteButtonAction(_ sender: Any) {
        model?.isFavorite.toggle()
        setFavoriteButton(isFavorite: model?.isFavorite ?? false)
        
        guard let model = model else { return }
        
        self.changeFavoritePublisher.send(model)
    }
    
}
