//
//  ExploreAchievmentsCell.swift
//  Evexia
//
//  Created by Oleg Pogosian on 06.01.2022.
//

import UIKit

class ExploreAchievmentsCell: UICollectionViewCell, CellIdentifiable {

    // MARK: - IBOutlets
    @IBOutlet weak var stepsCountLabel: UILabel!
    @IBOutlet weak var achievmentImage: UIImageView!
    @IBOutlet weak var achievmentDescriptionLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        achievmentImage.image = nil
        stepsCountLabel.text = nil
        achievmentDescriptionLabel.text = nil
    }
    
    // MARK: - UI
    private func setupUI() {
        self.layer.cornerRadius = 8
    }
    
    func configure(model: ExploreAchivmentModel) {
        stepsCountLabel.isHidden = model.count == nil
        stepsCountLabel.text = "\(model.count ?? 0)"
        
        if model.imageName.isEmpty {
            achievmentImage.image = UIImage(named: "activeStepAchieve")
        } else {
            achievmentImage.kf.setImage(url: model.imageName, sizes: nil, resize: false, placeholder: nil) { _ in
                self.changeColorImage(model: model)
            }
        }
        achievmentDescriptionLabel.text = model.descriptionText
        
    }

    func changeColorImage(model: ExploreAchivmentModel) {
        if !model.isActive {
            guard let currentCGImage = achievmentImage.image?.cgImage else { return }
            let currentCIImage = CIImage(cgImage: currentCGImage)

            let filter = CIFilter(name: "CIColorMonochrome")
            filter?.setValue(currentCIImage, forKey: "inputImage")

            // set a gray value for the tint color
            filter?.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.7), forKey: "inputColor")

            filter?.setValue(1.0, forKey: "inputIntensity")
            guard let outputImage = filter?.outputImage else { return }

            let context = CIContext()

            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                let processedImage = UIImage(cgImage: cgimg)
                achievmentImage.image = processedImage
            }
        }
    }
}
