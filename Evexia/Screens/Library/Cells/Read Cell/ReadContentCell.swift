//
//  ReadContentCell.swift
//  Evexia
//
//  Created by admin on 07.10.2021.
//

import UIKit
import Combine

class ReadContentCell: UITableViewCell, CellIdentifiable {

    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var changeFavoritePublisher = PassthroughSubject<ContentModel, Never>()
    var model: ContentModel?
    var cancellables = Set<AnyCancellable>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func draw(_ rect: CGRect) {
        self.shadowView.layer.borderWidth = 1.0
        self.shadowView.layer.borderColor = UIColor.gray400.cgColor
        self.shadowView.layer.cornerRadius = 8.0
    }
    
    @IBAction func favoriteButtonDidTap(_ sender: UIButton) {
        guard let model = self.model else { return }
        
        model.isFavorite.toggle()
        setFavoriteButtonImage(model.isFavorite)
        changeFavoritePublisher.send(model)
    }

    func configCell(with model: ContentModel) {
        self.model = model
        self.titleLabel.text = model.title
        self.authorLabel.text = model.author.username
        
        setFavoriteButtonImage(model.isFavorite)
    }
    
    private func setFavoriteButtonImage(_ isFavorite: Bool) {
        let imageString = isFavorite ? "favorite" : "unfavorite"
        let image = UIImage(named: imageString)
        self.favoriteButton.setImage(image, for: .normal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()

    }
}
