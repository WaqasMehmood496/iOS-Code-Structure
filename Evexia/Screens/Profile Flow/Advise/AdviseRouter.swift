//
//  AdviseRouter.swift
//  Evexia
//
//  Created by admin on 25.10.2021.
//

import Foundation
import UIKit

class AdviseRouter: Router<AdviseVC> {
    
    func mail(to email: String) {
        
        let gmailUrl = URL(string: "googlegmail://co?to=\(email)")
        let defaultUrl = URL(string: "mailto:\(email)")
        
        if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
            UIApplication.shared.open(gmailUrl)
        } else if let defaultUrl = defaultUrl {
            UIApplication.shared.open(defaultUrl)
        }
    }
    
    func call(number: String) {
        let url = URL(string: "tel://" + number)
        if let url = url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func open(_ url: URL) {
        UIApplication.shared.open(url)
    }
}
