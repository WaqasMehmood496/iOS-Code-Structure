//
//  NavigationBarAppearence.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 01.09.2021.
//

import UIKit

extension UINavigationBarAppearance {
    func setDefaultNavBar(color: UIColor = .clear) {
        UINavigationBar.appearance().tintColor = .gray700
        UINavigationBar.appearance().backgroundColor = color
        UINavigationBar.appearance().backIndicatorImage = UIImage(named: "arrow_left")?.withAlignmentRectInsets(.init(top: 0, left: -6, bottom: 0, right: 0))
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "arrow_left")
        UINavigationBar.appearance().shadowImage = UIImage()
    }
}

struct NavigationBarAppearence {

    let tintColor: UIColor?
    let barTintColor: UIColor?
    let backgroundImage: Image
    let shadowImage: Image
    let isTranslucent: Bool
    let titleTextAttributes: [NSAttributedString.Key: Any]

    init(
        tintColor: UIColor?,
        barTintColor: UIColor?,
        backgroundImage: Image,
        shadowImage: Image,
        isTranslucent: Bool,
        titleTextAttributes: [NSAttributedString.Key: Any]?
    ) {
        self.tintColor = tintColor
        self.barTintColor = barTintColor
        self.backgroundImage = backgroundImage
        self.shadowImage = shadowImage
        self.isTranslucent = isTranslucent
        self.titleTextAttributes = titleTextAttributes ?? [.foregroundColor: (tintColor ?? UIColor.black)]
    }

}

extension NavigationBarAppearence {

    enum Image {

        case `default`
        case empty
        case color(UIColor)

    }

}

extension NavigationBarAppearence {

    func apply(for navigationBar: UINavigationBar) {
        navigationBar.tintColor = tintColor
        navigationBar.isTranslucent = isTranslucent
        applyNewAppearnce(for: navigationBar)
    }

    private func applyNewAppearnce(for navigationBar: UINavigationBar) {
        let navigationBarAppearence = UINavigationBarAppearance()

        switch backgroundImage {
        case .default:
            navigationBarAppearence.configureWithDefaultBackground()
        case .empty:
            navigationBarAppearence.configureWithTransparentBackground()
            navigationBarAppearence.backgroundImage = UIImage()
        case .color(let color):
            navigationBarAppearence.configureWithOpaqueBackground()
            navigationBarAppearence.backgroundColor = color
        }

        switch shadowImage {
        case .default:
            navigationBarAppearence.shadowImage = nil
            navigationBarAppearence.shadowColor = nil
        case .empty:
            navigationBarAppearence.shadowImage = UIImage()
            navigationBarAppearence.shadowColor = .gray500
        case .color(let color):
            navigationBarAppearence.shadowImage = nil
            navigationBarAppearence.shadowColor = color
        }

        navigationBarAppearence.titleTextAttributes = titleTextAttributes

        navigationBar.standardAppearance = navigationBarAppearence
        navigationBar.compactAppearance = navigationBarAppearence
        navigationBar.scrollEdgeAppearance = navigationBarAppearence
    }
}
