//
//  MyGoalsSectionHeader.swift
//  Evexia
//
//  Created by  Artem Klimov on 19.07.2021.
//

import UIKit

class MyGoalsSectionHeader: UITableViewHeaderFooterView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let backgroundView = UIView(frame: self.bounds)
        backgroundView.backgroundColor = .clear
        self.backgroundView = backgroundView
    }
    
    @IBOutlet weak var focusImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    static var identifier: String {
        return String(describing: Self.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: self.identifier, bundle: nil)
    }

    func configHeader(with focus: Focus) {
        self.focusImageView.image = UIImage(named: focus.image_key)
        self.titleLabel.text = focus.headerTitle
    }
}
