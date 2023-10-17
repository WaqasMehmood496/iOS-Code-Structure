//
//  BenefitsRouter.swift
//  Evexia
//
//  Created by admin on 26.10.2021.
//

import UIKit

class BenefitsRouter: Router<BenefitsVC> {
    func open(_ url: URL) {
        UIApplication.shared.open(url)
    }
}
