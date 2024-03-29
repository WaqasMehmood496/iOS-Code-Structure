//
//  MyAvailabilityHeaderView.swift
//  Evexia Staging
//
//  Created by  Artem Klimov on 26.07.2021.
//

import UIKit

class MyAvailabilityHeaderView: UITableViewHeaderFooterView {
    
    static var identifier: String {
        return String(describing: Self.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: self.identifier, bundle: nil)
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        let view = UIView(frame: self.bounds)
        view.backgroundColor = .white
        self.backgroundView = view
    }
}
