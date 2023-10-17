//
//  BaseTextField.swift
//  Evexia Staging
//
//  Created by  Artem Klimov on 25.06.2021.
//

import UIKit
import Combine

class BaseTextField: UITextField {

    let picker: MyPickerView = MyPickerView()

    var didSelect = PassthroughSubject<Void, Never>()
    
    @IBInspectable var cornerRadius: CGFloat = 16.0 {
        didSet {
            layer.cornerRadius = self.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor = .lightGray {
        didSet {
            layer.borderColor = self.borderColor.cgColor
        }
    }
    
    @IBInspectable var showRightButton: Bool {
        get {
            return self._showRightButton
        }
        set {
            _showRightButton = newValue
            self.rightViewMode = showRightButton ? .always : .never
        }
    }
    
    var fieldState: TextFieldState = .normal

    var rightViewButton: UIButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0))
    var floatLabel: UILabel?
    private let padding = UIEdgeInsets(top: 31.0, left: 20.0, bottom: 9.0, right: 20.0)
    private let placeholderPadding = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 0.0)
    private var _showRightButton = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.defaultInit()
        bindPickerSelect()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.defaultInit()
        bindPickerSelect()
    }
    
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = self.cornerRadius
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.placeholderPadding)
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rightViewRect = CGRect()
            rightViewRect = self.rightViewButton.frame
            rightViewRect.origin.y = 17.0
            rightViewRect.origin.x = bounds.width - rightViewButton.frame.width - 15.0
        return rightViewRect
    }
    
    internal func setState(for state: TextFieldState) {
        self.fieldState = state
        
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundColor = state.style.backgroundColor
            self.floatLabel?.font = UIFont(name: "Outfit-Light", size: state.style.placeholderHeight)
            self.floatLabel?.textColor = state.style.placeholderColor
        })
        
        DispatchQueue.main.async { [weak self] in
            self?.animateBorderColor(toColor: state.style.borderColor, duration: 0.3)
            self?.animateBorderWidth(toWidth: state.style.borderWidth, duration: 0.3)
        }
    }

    func setupPicker(components: [MetricData]) {
        picker.components = components
        picker.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        picker.backgroundColor = .white

        inputView = picker
    }

    func setupPickerAccessory() {
        let pickerAccessory = UIToolbar()
        pickerAccessory.autoresizingMask = .flexibleHeight

        //this customization is optional
        pickerAccessory.barStyle = .default
        pickerAccessory.barTintColor = .orange
        pickerAccessory.backgroundColor = .orange
        pickerAccessory.isTranslucent = false

        var frame = pickerAccessory.frame
        frame.size.height = 44.0
        pickerAccessory.frame = frame

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelBtnClicked(_:)))
        cancelButton.tintColor = .white
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) //a flexible space between the two buttons
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnClicked(_:)))
        doneButton.tintColor = .white

        //Add the items to the toolbar
        pickerAccessory.items = [cancelButton, flexSpace, doneButton]

        inputAccessoryView = pickerAccessory
    }
    
    internal func defaultInit() {
        self.font = UIFont(name: "Outfit-Light", size: 16.0)
        self.autocorrectionType = .no
        self.borderStyle = .none
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.gray8F.cgColor
        self.layer.cornerRadius = self.cornerRadius
        self.clipsToBounds = true
        self.backgroundColor = .white
        self.tintColor = .gray8F

        self.rightView = self.rightViewButton
        
        self.setupPlaceholderLabel(text: self.placeholder)
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [NSAttributedString.Key.font: UIFont(name: "Outfit-Light", size: 16.0)! ] )
    
        addTarget(self, action: #selector(showLabel), for: .editingDidBegin)
        addTarget(self, action: #selector(checkLabel), for: .editingDidEnd)
    }

    private func bindPickerSelect() {
        picker.didSelectCompletion = { [weak self] text in
            self?.text = text
            self?.didSelect.send()
        }
    }
    
    private func setupPlaceholderLabel(text: String?) {
        guard self.floatLabel == nil else { return }
        let label = UILabel()
        label.frame = CGRect(x: 20, y: 9, width: self.bounds.width - 20, height: 20)
        label.font = .systemFont(ofSize: 14.0)
        label.text = text
        label.alpha = 0
        self.floatLabel = label
        self.addSubview(label)
    }
    
    private func animateBorderColor(toColor: UIColor, duration: Double) {
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = layer.borderColor
        animation.toValue = toColor.cgColor
        animation.duration = duration
        layer.add(animation, forKey: "borderColor")
        layer.borderColor = toColor.cgColor
    }
    
    private func animateBorderWidth(toWidth: CGFloat, duration: Double) {
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "borderWidth")
        animation.fromValue = layer.borderWidth
        animation.toValue = toWidth
        animation.duration = duration
        layer.add(animation, forKey: "borderWidth")
        layer.borderWidth = toWidth
    }
    
    func setText(_ text: String?) {
        self.text = text
        if !(self.text?.isEmpty ?? true) {
            self.floatLabel?.alpha = 1.0
        }
        self.setState(for: .normal)
    }
    
    enum AnimationType: CGFloat {
        case show = 1.0
        case hide = 0.0
    }

    /**
     Called when the cancel button of the `pickerAccessory` was clicked. Dismsses the picker
     */
    @objc
    func cancelBtnClicked(_ button: UIBarButtonItem?) {
        resignFirstResponder()
    }

    /**
     Called when the done button of the `pickerAccessory` was clicked. Dismisses the picker and puts the selected value into the textField
     */
    @objc
    func doneBtnClicked(_ button: UIBarButtonItem?) {
        resignFirstResponder()
        text = picker.selectedValue
    }
    
    @objc
    func checkLabel() {
        if self.text?.isEmpty ?? true {
            self.toggleFloatLabel(animation: .hide)
        }
    }
    
    @objc
    func showLabel() {
        self.attributedPlaceholder = NSAttributedString(string: "")
        self.toggleFloatLabel(animation: .show)
    }
    
    func toggleFloatLabel(animation: AnimationType) {
        self.placeholder = animation == .show ? "" : self.floatLabel?.text
        UIView.animate(withDuration: 0.3, animations: {
            self.floatLabel?.alpha = animation.rawValue
        })
    }
}
