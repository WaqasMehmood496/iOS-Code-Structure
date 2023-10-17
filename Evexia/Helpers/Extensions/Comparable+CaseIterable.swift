//
//  Comparable.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 25.08.2021.
//

import Foundation

extension Comparable where Self: CaseIterable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        guard let lhsIndex = allCases.firstIndex(of: lhs), let rhsIndex = allCases.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex
    }
}
