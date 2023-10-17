//
//  PDCategoryDetailsRouter.swift
//  Evexia Staging
//
//  Created by Oleg Pogosian on 09.12.2021.
//

import Foundation
import UIKit

class PDCategoryDetailsRouter: Router<PDCategoryDetailsVC> {
    
    func openBrowser(url: String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url)
    }
    
}
