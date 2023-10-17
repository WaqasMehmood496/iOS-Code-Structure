//
//  ImpactCell.swift
//  Evexia
//
//  Created by Oleksand Kovalov on 15.02.2022.
//

import UIKit
import Combine

// MARK: - ImpactCell
class ImpactCell: UICollectionViewCell, CellIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var cornerView: UIView!
    @IBOutlet private weak var seeImpactButton: UIButton!
    
    // MARK: - Properties
    let seeImpact = PassthroughSubject<Void, Never>()
    
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.cancellables.forEach { $0.cancel() }
        self.cancellables.removeAll()
        
    }
}

// MARK: - Private Extension
extension ImpactCell {
    private func setupUI() {
        cornerView.layer.cornerRadius = 10
        seeImpactButton.layer.cornerRadius = 16
    }
}

// MARK: - Action
extension ImpactCell {
    @IBAction func seeImpactDidTap() {
        seeImpact.send()
    }
}
