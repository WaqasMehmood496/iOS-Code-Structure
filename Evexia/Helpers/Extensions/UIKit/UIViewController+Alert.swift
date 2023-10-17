//
//  UIViewController+Alert.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 10.09.2021.
//

import UIKit

struct AlertButton {
    let title: String
    let style: UIAlertAction.Style
    let action: Closure
}

extension UIViewController {

    func showAllert(
        alertStyle: UIAlertController.Style,
        title: String? = nil,
        message: String? = nil,
        actions: [AlertButton]
        ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        
        actions.forEach { action in
            let action = UIAlertAction(title: action.title, style: action.style) { _ in
                action.action()
            }
            alertController.addAction(action)
        }
        
        present(alertController, animated: true, completion: nil)
    }
}
