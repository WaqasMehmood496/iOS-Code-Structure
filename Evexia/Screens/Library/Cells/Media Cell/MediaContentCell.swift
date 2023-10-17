//
//  LibraryContentCell.swift
//  Evexia
//
//  Created by admin on 04.10.2021.
//

import UIKit
import Kingfisher
import Combine

class MediaContentCell: UITableViewCell, CellIdentifiable {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var videoPreviewImageView: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    var playPublisher = PassthroughSubject<ContentModel?, Never>()
    var changeFavoritePublisher = PassthroughSubject<ContentModel, Never>()
    var model: ContentModel?
    var cancellables = Set<AnyCancellable>()
    
    @IBAction func playButtonDidTap(_ sender: UIButton) {
        self.playPublisher.send(model)
    }
    
    @IBAction func favoriteButtonDidTap(_ sender: UIButton) {
        guard let model = self.model else { return }
        
        model.isFavorite.toggle()
        setFavoriteButtonImage(model.isFavorite)
        changeFavoritePublisher.send(model)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.playButton.setImage(UIImage(named: "ico_community_play")?.withRenderingMode(.alwaysOriginal), for: .normal)}
    
    override func draw(_ rect: CGRect) {
        self.previewImageView.layer.cornerRadius = 8.0
        self.videoPreviewImageView.layer.cornerRadius = 8.0
    }
    
    func configCell(with model: ContentModel) {
        self.authorLabel.text = model.author.username
        self.titleLabel.text = model.title
        self.model = model
        
        setFavoriteButtonImage(model.isFavorite)
        
        switch model.fileType {
        case .video:
            self.videoPreviewImageView.kf.setImage(url: model.placeholder, sizes: videoPreviewImageView.bounds.size, placeholder: UIImage(named: "play_inactive"), completionHandler: { [weak self] result in
                switch result {
                case let .success(value):
                    if value.image.size.height < value.image.size.width {
                        self?.videoPreviewImageView.contentMode = .scaleAspectFit
                    } else {
                        self?.videoPreviewImageView.contentMode = .scaleAspectFill
                    }
                case .failure:
                    break
                }
            })
            self.previewImageView.isHidden = true
            self.videoPreviewImageView.isHidden = false
            self.playButton.isHidden = false
        case .audio:
            self.previewImageView.kf.setImage(url: model.placeholder, sizes: previewImageView.bounds.size, placeholder: UIImage(named: "headphones"))
            self.previewImageView.isHidden = false
            self.favoriteButton.isHidden = false
            self.playButton.isHidden = true
        case .pdf:
            break
        }
    }
    
    private func setFavoriteButtonImage(_ isFavorite: Bool) {
        let imageString = isFavorite ? "favorite" : "unfavorite"
        let image = UIImage(named: imageString)
        self.favoriteButton.setImage(image, for: .normal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.previewImageView.image = nil
        self.videoPreviewImageView.image = nil
        self.videoPreviewImageView.isHidden = true
        self.previewImageView.isHidden = true

        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()

    }
}
