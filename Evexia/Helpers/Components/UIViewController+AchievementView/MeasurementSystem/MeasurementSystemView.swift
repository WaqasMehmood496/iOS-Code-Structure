//
//  MeasurementSystemView.swift
//  Evexia
//
//  Created by Александр Ковалев on 16.11.2022.
//

import UIKit
import SwiftEntryKit

class MeasurementSystemView: UIView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var saveButton: UIButton!
    
    @IBOutlet private weak var metricView: UIView!
    @IBOutlet private weak var metricLabel: UILabel!
    @IBOutlet private weak var metricCheckBox: Checkbox!
    
    @IBOutlet private weak var imperialView: UIView!
    @IBOutlet private weak var imperialLabel: UILabel!
    @IBOutlet private weak var imperialCheckBox: Checkbox!

    @IBOutlet private weak var cornerView: UIView!
    
    // MARK: - Properties
    private let message: EKPopUpMessage
    private var measurementType: MeasurementSystemType = .uk
    
    // MARK: - Init
    init(with message: EKPopUpMessage) {
        self.message = message
        super.init(frame: UIScreen.main.bounds)
        nibSetup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func cancelDidTap() {
        SwiftEntryKit.dismiss()
    }
    
    @IBAction func saveDidTap() {
        UserDefaults.measurement = measurementType.rawValue
        message.action()
    }
}

private extension MeasurementSystemView {
    func setupUI() {
        titleLabel.font = UIFont(name: "NunitoSans-Bold", size: 24)
        titleLabel.textColor = .gray900
        titleLabel.text = message.title.text
        
        subTitleLabel.font = UIFont(name: "NunitoSans-Regular", size: 16)
        subTitleLabel.textColor = .gray700
        subTitleLabel.text = message.description.text
        
        cancelButton.titleLabel?.font = UIFont(name: "NunitoSans-Semibold", size: 20)
        cancelButton.setTitleColor(.gray900, for: .normal)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.gray500.cgColor
        
        saveButton.titleLabel?.font = UIFont(name: "NunitoSans-Semibold", size: 20)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitle("Save", for: .normal)
        saveButton.layer.cornerRadius = 16

        saveButton.backgroundColor = .orange
        
        cornerView.layer.cornerRadius = 16
        
        setupShadow()
        
        metricCheckBox.selected()
        setupGesture()
    }
    
    func setupGesture() {
        metricView.tag = 0
        imperialView.tag = 1
        
        let metricTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapToCheckBox))
        
        metricView.isUserInteractionEnabled = true
        metricView.addGestureRecognizer(metricTapGesture)
        
        let imperailTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapToCheckBox))
        
        imperialView.isUserInteractionEnabled = true
        imperialView.addGestureRecognizer(imperailTapGesture)
        
        
    }
    
    @objc
    func didTapToCheckBox(sender: UITapGestureRecognizer) {
        guard sender.view?.tag == 0 && !metricCheckBox.isSelected || sender.view?.tag == 1 && !imperialCheckBox.isSelected else {
            return
        }
        measurementType = sender.view?.tag == 0 ? .metric : .us
        imperialCheckBox.selected()
        metricCheckBox.selected()
    }
    
    func nibSetup() {
        let nib = UINib(nibName: String(describing: MeasurementSystemView.self), bundle: nil)
        
        if let view = nib.instantiate(withOwner: self).first as? UIView {
            addSubview(view)
            view.frame = bounds
        }
        setupUI()
    }
    
    func setupShadow() {
        [metricView, imperialView].forEach {
            $0?.layer.cornerRadius = 8.0
            $0?.layer.shadowRadius = 6.0
            $0?.layer.shadowOffset = .zero
            $0?.layer.shadowColor = UIColor.gray400.cgColor
            $0?.layer.shadowOpacity = 0.5
            $0?.layer.shadowPath = UIBezierPath(roundedRect: $0?.bounds ?? .init(origin: .zero, size: .zero), cornerRadius: 8.0).cgPath
            $0?.layer.borderWidth = 1
            $0?.layer.borderColor = UIColor.gray300.cgColor
        }
    }
}
