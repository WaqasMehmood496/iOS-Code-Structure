//
//  BarItem.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 30.08.2021.
//

import Charts

struct BarItem {
    let index: Int
    let value: Double
    
    func transformToBarChartDataEntry() -> BarChartDataEntry {
        let entry = BarChartDataEntry(x: Double(index), y: value)
        return entry
    }
}
