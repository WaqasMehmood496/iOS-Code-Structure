//
//  CountryHeader.swift
//  Evexia Staging
//
//  Created by  Artem Klimov on 09.08.2021.
//

import UIKit

class CountryHeader: UITableViewHeaderFooterView {

    @IBOutlet private weak var titleLabel: UILabel!
    
    static var identifier: String {
        return String(describing: Self.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: self.identifier, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let backgroundView = UIView(frame: self.bounds)
        backgroundView.backgroundColor = .white
        self.backgroundView = backgroundView
    }

    func configHeader(with title: String) {
        self.titleLabel.text = title
    }
}
