//
//  MetricSystem.swift
//  Evexia
//
//  Created by Александр Ковалев on 28.11.2022.
//

import Foundation

var isMetricSystem: Bool {
    return (MeasurementSystemType(rawValue: UserDefaults.measurement) ?? .uk) == .uk
}

struct MeasurObject {
    let fullTitle: String
    let roundedFullTitle: String
    let value: String
    let symbol: String
    let doubleValue: Double

    static var emptyState: MeasurObject {
        return .init(fullTitle: "", roundedFullTitle: "", value: "", symbol: "", doubleValue: 0)
    }
}

struct MetricData {
    let name: String
    let data: [Int]
}

enum MeasurementSystemType: String {
    case us = "U.S."
    case uk = "U.K."
    case metric = "Metric"

    var title: String {
        switch self {
        case .us:
            return "Imperial"
        case .uk, .metric:
            return "Metric"
        }
    }

    var data: (height: [MetricData], weight: [MetricData]) {
        switch self {
        case .us:
            let ftImp = (1...9).map { $0 }
            let inImp = (0...9).map { $0 }
            let height = [MetricData(name: "ft", data: ftImp), MetricData(name: "in", data: inImp)]

            let stImp = (1...78).map { $0 }
            let lbImp = (0...13).map { $0 }
            let weight = [MetricData(name: "st", data: stImp), MetricData(name: "lb", data: lbImp)]

            return (height, weight)
        case .uk, .metric:
            return ([], [])
        }
    }

}

enum UnitsType {
    case lengh
    case mass
}
