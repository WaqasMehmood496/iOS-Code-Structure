//
//  ProgressView.swift
//  Evexia
//
//  Created by admin on 11.09.2021.
//

import Foundation
import UIKit

class ProgressView: UIView {
    
    @IBOutlet private var view: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dailyLabel: UILabel!
    @IBOutlet private weak var weeklyLabel: UILabel!
    @IBOutlet private weak var ringsView: CircularProgressView!
    
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
        
        self.layer.cornerRadius = 16.0
        self.layer.masksToBounds = true
    }
    
    private func nibSetup() {
        backgroundColor = .clear
        self.view = loadViewFromNib()
        self.view.frame = bounds
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.translatesAutoresizingMaskIntoConstraints = true
        self.setupViews()
        addSubview(view)
    }
    
    private func setupViews() {
//        ringsView.progress = 0.5
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return nibView
    }
}
