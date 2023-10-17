//
//  PickerVC.swift
//  Evexia
//
//  Created by  Artem Klimov on 23.07.2021.
//

import UIKit
import Combine

class PickerVC: BaseViewController, StoryboardIdentifiable {
    
    @IBOutlet private weak var pickerView: UIPickerView!
    @IBOutlet private weak var saveChangesButton: RequestButton!
    @IBOutlet weak var closeButton: UIButton!

    internal var viewModel: PickerVM!
    private var rowHeight: CGFloat = 44.0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    private func setupUI() {
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.closeButton.layer.cornerRadius = 24.0
        
        if let selectedValue = self.viewModel.selected {
            if let index = viewModel.dataSource.firstIndex(where: { $0.title == selectedValue.title }) {
                self.pickerView.selectRow(index, inComponent: 0, animated: false)
            } else {
                self.setMiddleValueForPicker(with: self.viewModel.dataSource.count)
            }
        } else {
            self.setMiddleValueForPicker(with: self.viewModel.dataSource.count)
        }
    }
    
    private func setMiddleValueForPicker(with itemsCount: Int) {
        let middleValue = Int(Double(itemsCount) / 2.0)
        self.pickerView.selectRow(middleValue, inComponent: 0, animated: false)
        self.pickerView(self.pickerView, didSelectRow: middleValue, inComponent: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func saveChangesButtonDidTap(_ sender: RequestButton) {
        self.viewModel.dataClouser?(self.viewModel.selected?.title ?? "Not Set")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeButtonDidTap(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension PickerVC: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.viewModel.dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.viewModel.dataSource[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selected = self.viewModel.dataSource[row]
        self.viewModel.selected = selected
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return self.rowHeight
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label: UILabel
        if let v = view as? UILabel {
            label = v
        } else {
            label = UILabel()
        }
        
        label.textAlignment = .center
        label.font = UIFont(name: "NunitoSans-Semibold", size: 20.0)!
        
        label.text = self.viewModel.dataSource[row].title
        
        switch component {
        case 0:
            if pickerView.selectedRow(inComponent: 0) == row {
                label.textColor = UIColor.gray900
            }
            return label
            
        default:
            return label
        }
    }

}
