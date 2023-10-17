//
//  AdviseContentCell.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 18.08.2021.
//

import UIKit
import Combine
import Kingfisher

enum PositionCell {
    case first
    case last
    case middle
    case single
}

class AdviseContentCell: UITableViewCell, CellIdentifiable {
    
    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var topCellConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomCellConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func configure(with model: AdviseModel, position: PositionCell) {
        
        title.text = model.title
        setStateCellAssociatedWithPosition(position: position)
        
        guard let urlString = model.imageURL, let url = URL(string: urlString) else { return }
        let resource = ImageResource(downloadURL: url)
        
        KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil, downloadTaskUpdated: nil, completionHandler: { [weak self] result in
            switch result {
            case let .success(data):
                self?.title.addImageToTrailing(image: data.image)
            case .failure:
                return
            }
        })
    }
    
    func maskedCorners(masked: CACornerMask) {
        cornerView.layer.cornerRadius = 16
        cornerView.layer.maskedCorners = masked
    }
    
    func setStateCellAssociatedWithPosition(position: PositionCell) {
        switch position {
        case .first:
            maskedCorners(masked: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
            separatorView.isHidden = true
            topCellConstraint.constant = 24
        case .last:
            maskedCorners(masked: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
            bottomCellConstraint.constant = 24
        case .single:
            cornerView.layer.cornerRadius = 16
            separatorView.isHidden = true
            topCellConstraint.constant = 24
            bottomCellConstraint.constant = 24
        default: break
        }
    }
}
