//
//  OnboardingCell3.swift
//  Evexia
//
//  Created by Codes Orbit on 06/10/2023.
//

import UIKit
import Atributika

class OnboardingCell3: UICollectionViewCell, CellIdentifiable {

    
    // MARK: - IBOutlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: AttributedLabel!

    //MARK: - Properties
    private var plainAttributes: Style {
        return Style
            .foregroundColor(.blue84, .normal)
            .backgroundColor(.white)
            .font(UIFont(name: "Outfit-SemiBold", size: 24.0)!)
        
    }
    // MARK: - Cell Configuration
    func configure(with model: Onboarding) {
        textLabel.attributedText = model.text.styleAll(self.plainAttributes)
        textLabel.textAlignment = .center
    }
}
