//
//  SectionedProgressView.swift
//  Evexia
//
//  Created by  Artem Klimov on 14.07.2021.
//

import UIKit

class SectionedProgressView: UIView {
    
    private var sectionViews: [SectionedProgressSectionView] = []
    
    func setupSections(count: Int) {
        self.sectionViews.removeAll()
        let hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.spacing = 6.0
        let views = (0..<count).compactMap { _ -> SectionedProgressSectionView in
            let sectionView = SectionedProgressSectionView()
            return sectionView
        }
        self.sectionViews = views
        views.forEach { hStack.addArrangedSubview($0) }
        self.addSubview(hStack)
        hStack.translatesAutoresizingMaskIntoConstraints = false
        hStack.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        hStack.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        hStack.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        hStack.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        hStack.distribution = .fillEqually
    }
    
    func updateProgress(index: Int) {
        guard index < sectionViews.count else { return }
        sectionViews[index].backgroundColor = .orange
        guard index + 1 < sectionViews.count else { return }
        sectionViews[index + 1].backgroundColor = .gray400
    }
    
}

class SectionedProgressSectionView: UIView {
    
    private weak var colorView: UIView?
    
    convenience init() {
        self.init(frame: .zero)
        self.setupUI()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.cornerRadius = 2.0
    }
    private func setupUI() {
        self.backgroundColor = .gray400
        
        let colorView = UIView()
        colorView.layer.cornerRadius = 2.0
        self.addSubview(colorView)
        self.colorView = colorView
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        colorView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        colorView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        colorView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.clipsToBounds = true
    }
}
