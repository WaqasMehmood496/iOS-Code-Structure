//
//  NSMutableData+Extension.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 15.09.2021.
//

import Foundation

extension NSMutableData {

    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
