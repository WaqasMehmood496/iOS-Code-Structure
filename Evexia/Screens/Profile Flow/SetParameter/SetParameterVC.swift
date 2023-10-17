//
//  SetParameterVC.swift
//  Evexia
//
//  Created by  Artem Klimov on 29.07.2021.
//

import Foundation
import Combine
import UIKit

class SetParameterVC: BaseViewController, StoryboardIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var contentStackView: UIStackView!
    @IBOutlet private weak var firstNameErrorLabel: UILabel!
    @IBOutlet private weak var lastNameErrorLabel: UILabel!
    @IBOutlet private weak var emailErrorLabel: UILabel!
    @IBOutlet private weak var weightErrorLabel: UILabel!
    @IBOutlet private weak var heightErrorLabel: UILabel!
    @IBOutlet private weak var ageErrorLabel: UILabel!
    
    @IBOutlet private weak var heightView: UIStackView!
    @IBOutlet private weak var weightView: UIStackView!
    @IBOutlet private weak var emailView: UIStackView!
    @IBOutlet private weak var nameView: UIStackView!
    @IBOutlet private weak var ageView: UIStackView!
    
    @IBOutlet private weak var firstNameTextField: NameTextField!
    @IBOutlet private weak var lastNameTextField: NameTextField!
    @IBOutlet private weak var emailTextField: EmailTextField!
    @IBOutlet private weak var weightTextField: WeightTextField!
    @IBOutlet private weak var heightTextField: HeightTextField!
    @IBOutlet private weak var ageTextField: AgeTextField!
    @IBOutlet private weak var saveChangesButton: RequestButton!
    @IBOutlet private weak var setButtonConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    var viewModel: SetParameterVM!
    
    private var buttonButtomPadding: CGFloat = 24.0
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        (self.tabBarController as? TabBarController)?.setTabBarHidden(true, animated: false)
        self.setupUI()
        self.setupKeyboardNotifications()
        self.binding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupUI() {
        self.setupNavigationBar()
        self.setupFields()
        self.setupTextFields()
        self.setupLabels()
    }
    
    private func setupLabels() {
        self.emailErrorLabel.text = "Invalid email address, please try again".localized()
        self.firstNameErrorLabel.text = "Your first name can't contain more than 20 characters".localized()
        self.lastNameErrorLabel.text = "Your last name can't contain more than 20 characters".localized()
        self.weightErrorLabel.text = "Weight value must be in a range between 20 and 500 kg".localized()
        self.heightErrorLabel.text = "Height value must be in a range between 40 and 300 cm".localized()
        self.ageErrorLabel.text = "Age value must be in range between 0 and 120".localized()
    }
    
    private func binding() {
        self.viewModel.userModel
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] user in
                self?.firstNameTextField.setText(user?.firstName)
                self?.lastNameTextField.setText(user?.lastName)
                self?.emailTextField.setText(user?.email)
                self?.weightTextField.setText(user?.weight)
                self?.heightTextField.setText(user?.height)
                self?.ageTextField.setText(user?.age)
                self?.validateInputText()
                
                let weight = "Weight".getUnitWithSybmols(unitType: .mass, isNeedBracket: true)
                let height = "Height".getUnitWithSybmols(unitType: .lengh, isNeedBracket: true)
                self?.weightTextField.placeholder = weight
                self?.weightTextField.floatLabel?.text = weight
                self?.heightTextField.placeholder = height
                self?.heightTextField.floatLabel?.text = height
            }).store(in: &self.cancellables)
        
        self.firstNameTextField.isValidInput
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { [weak self] isValid in
                self?.updateErrorLabel(label: self?.firstNameErrorLabel, isValid: isValid)
            }).store(in: &cancellables)
        
        self.lastNameTextField.isValidInput
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { [weak self] isValid in
                self?.updateErrorLabel(label: self?.lastNameErrorLabel, isValid: isValid)
            }).store(in: &cancellables)
        
        self.emailTextField.isValidInput
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { [weak self] isValid in
                self?.updateErrorLabel(label: self?.emailErrorLabel, isValid: isValid)
            }).store(in: &cancellables)
        
        self.heightTextField.isValidInput
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { [weak self] isValid in
                self?.updateErrorLabel(label: self?.heightErrorLabel, isValid: isValid)
            }).store(in: &cancellables)
        
        self.weightTextField.isValidInput
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { [weak self] isValid in
                self?.updateErrorLabel(label: self?.weightErrorLabel, isValid: isValid)
            }).store(in: &cancellables)
        
        self.ageTextField.isValidInput
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { [weak self] isValid in
                self?.updateErrorLabel(label: self?.ageErrorLabel, isValid: isValid)
            }).store(in: &cancellables)
        
        self.viewModel.isSaveAvailabel
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: self.saveChangesButton)
            .store(in: &self.cancellables)
        
        self.viewModel.errorPublisher
            .removeDuplicates()
            .sink(receiveValue: { [weak self] serverError in
                self?.modalAlert(modalStyle: serverError.errorCode)
            }).store(in: &self.cancellables)
        
        self.viewModel.isRequestAction
            .removeDuplicates()
            .sink(receiveValue: { [weak self] isRequestAction in
                self?.saveChangesButton.isRequestAction.send(isRequestAction)
            }).store(in: &self.cancellables)

        self.weightTextField.didSelect
            .sink(receiveValue: { [weak self] in
                guard !isMetricSystem else {
                    return
                }
                self?.viewModel.weight.send(self?.weightTextField.text ?? "")
            }).store(in: &cancellables)

        self.heightTextField.didSelect
            .sink(receiveValue: { [weak self] in
                guard !isMetricSystem else {
                    return
                }
                self?.viewModel.height.send(self?.heightTextField.text ?? "")
            }).store(in: &cancellables)
    }
    
    private func updateErrorLabel(label: UILabel?, isValid: Bool) {
        UIView.animate(withDuration: 0.2, animations: {
            label?.isHidden = isValid
            label?.alpha = isValid ? 0.0 : 1.0
            self.contentStackView.layoutIfNeeded()
        })
    }
    
    private func setupTextFields() {
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        self.emailTextField.delegate = self
        self.weightTextField.delegate = self
        self.heightTextField.delegate = self
        self.ageTextField.delegate = self
    }
    
    func setupNavigationBar() {
        //        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "arrow_left"), style: .plain, target: self, action: #selector(backNavigation(_:)))
        self.navigationItem.title = self.viewModel.type.title
        
    }
    
    private func setupFields() {
        switch viewModel.type {
        case .email:
            self.emailView.isHidden = false
        case .name:
            self.nameView.isHidden = false
        case .height:
            self.heightView.isHidden = false
        case .weight:
            self.weightView.isHidden = false
        case .age:
            self.ageView.isHidden = false
        default:
            break
        }
    }
    
    @objc
    func backNavigation(_ sender: Any?) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func validateInputText() {
        self.viewModel.firstName.send(firstNameTextField.text ?? "")
        self.viewModel.lastName.send(lastNameTextField.text ?? "")
        self.viewModel.weight.send(weightTextField.text ?? "")
        self.viewModel.height.send(heightTextField.text ?? "")
        self.viewModel.email.send(emailTextField.text ?? "")
        self.viewModel.age.send(ageTextField.text ?? "")
    }
    
    @IBAction func saveChangesButtonDidTap(_ sender: RequestButton) {
        self.viewModel.saveChanges()
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func bindPickerInTF(field: BaseTextField) {
        guard (viewModel.type == .weight || viewModel.type == .height), !isMetricSystem else {
            return
        }

        guard let text = field.text, let generalValue = Double(text) else {
            return
        }

        let roundDouble = round(generalValue * 10) / 10.0
        let intValue = Int(roundDouble)
        let decimalValue = Int(round(roundDouble.truncatingRemainder(dividingBy: 1) * 10))
        var textFromPicker = ""

        for i in 0...1 {
            if let index = field.picker.components[i].data.firstIndex(where: { i == 0 ? $0 == intValue : $0 == decimalValue }) {
                field.picker.selectRow(index, inComponent: i, animated: false)
            } else if let startValue = field.picker.components[i].data.first {
                textFromPicker += "\(startValue)\(i == 0 ? "." : "")"
            }
        }
    }
    
    @objc
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        self.setButtonConstraint.constant = keyboardFrame.size.height
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc
    func keyboardWillHide(notification: NSNotification) {
        self.setButtonConstraint.constant = self.buttonButtomPadding
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
}

// MARK: - UITextFieldDelegate
extension SetParameterVC: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.validateInputText()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.validateInputText()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let field = textField as? BaseTextField else { return }
        field.setState(for: .editing)
        bindPickerInTF(field: field)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch viewModel.type {
        case .weight, .height, .age:
            if (textField.text ?? "").isEmpty && string == "0" {
                return false
            }
            if string == "." {
                return false
            }
            let allowedCharacterSet = CharacterSet(charactersIn: "0123456789")
            let textCharacterSet = CharacterSet(charactersIn: textField.text ?? "" + string)
            if !allowedCharacterSet.isSuperset(of: textCharacterSet) {
                return false
            }
            return true
            
        case .name:
            if textField.text?.count ?? 0 == 0 && string == " " {
                return false
            }
            let count = ((textField.text ?? "") + string).count
            return count <= 20
        default:
            return true
        }
    }
}
