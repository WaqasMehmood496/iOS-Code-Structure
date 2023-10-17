//
//  MyImpactProfileCell.swift
//  Evexia Staging
//
//  Created by admin on 20.07.2022.
//

import UIKit
import Combine

class MyImpactProfileCell: UITableViewCell, CellIdentifiable {

    @IBOutlet weak var impactCountLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    
    var statisticNavigationPublisher = PassthroughSubject<ProfileStatistic, Never>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        setupUI()
    }
    
    private func setupUI() {
        shadowView.layer.shadowColor = UIColor.gray400.cgColor
        shadowView.layer.shadowRadius = 6.0
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.shadowOffset = .zero
        shadowView.layer.shadowPath = UIBezierPath(rect: shadowView.bounds).cgPath
    }
    
    func configCell(count: Double?) {
        if let value = count {
            let text = String(value).replacingOccurrences(of: ",", with: ".")
            impactCountLabel.text = text
        } else {
            impactCountLabel.text = "-"
        }
       
    }
}
