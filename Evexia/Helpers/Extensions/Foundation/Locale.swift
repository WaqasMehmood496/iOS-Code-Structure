//
//  Locale.swift
//  Evexia
//
//  Created by Александр Ковалев on 15.11.2022.
//

import Foundation

extension Locale {
    var measurementSystem: MeasurementSystemType{
        let string = (self as NSLocale).object(forKey: NSLocale.Key.measurementSystem) as! String
        
        return MeasurementSystemType(rawValue: string)!
    }
}
