//
//  UIViewController+Extension.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 01.09.2021.
//

import UIKit

extension UIViewController {
    func applyDefaultNavigationBarStyle(shadow: Bool = false) {
        if let navigationBar = navigationController?.navigationBar {
            NavigationBarAppearence(
                tintColor: .black,
                barTintColor: .white,
                backgroundImage: .color(.white),
                shadowImage: shadow ? .default : .empty,
                isTranslucent: false,
                titleTextAttributes: nil
            ).apply(for: navigationBar)
        } else {
            navigationController?.navigationBar.isTranslucent = false
            navigationController?.navigationBar.tintColor = UIColor.white
            navigationController?.navigationBar.barTintColor = .white
            navigationController?.navigationBar.backgroundColor = .white
            navigationController?.navigationBar.shadowImage = shadow ? nil : UIImage()
        }
    }

    func applyDefaultTitle(_ title: String?) {
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationItem.title = title
    }
}
