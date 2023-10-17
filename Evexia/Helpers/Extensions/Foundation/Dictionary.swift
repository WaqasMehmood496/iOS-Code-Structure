//
//  Dictionary.swift
//  Evexia
//
//  Created by admin on 25.10.2021.
//

import Foundation

extension Dictionary where Value: Equatable {
    func key(forValue value: Value) -> Key? {
        return first { $0.1 == value }?.0
    }
}
