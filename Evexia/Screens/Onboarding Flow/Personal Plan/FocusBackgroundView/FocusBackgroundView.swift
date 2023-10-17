//
//  FocusBackgroundView.swift
//  Evexia
//
//  Created by  Artem Klimov on 16.07.2021.
//

import UIKit

class FocusBackgroundView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.nibSetup()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.view.layer.cornerRadius = 6.0
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return nibView
    }
    
    private func nibSetup() {
        backgroundColor = .clear
        self.view = loadViewFromNib()
        imageView.tintColor = nil
        imageView.tintColor = .white
        self.view.frame = bounds
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.translatesAutoresizingMaskIntoConstraints = true
        addSubview(view)
    }
}
