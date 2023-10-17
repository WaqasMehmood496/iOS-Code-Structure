//
//  ViewController.swift
//  KeyboardTest
//
//  Created by Александр Ковалев on 14.11.2022.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.textContentType = .username
        passwordTextField.textContentType = .password
    }


}

