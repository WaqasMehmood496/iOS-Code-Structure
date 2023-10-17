//
//  ImagePicker.swift
//  Evexia
//
//  Created by  Artem Klimov on 28.07.2021.
//

import Foundation
import UIKit

class ImagePicker: UIImagePickerController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UINavigationBar.appearance().tintColor = .gray700
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let appearance = UINavigationBarAppearance()
        appearance.setDefaultNavBar()
    }
}
