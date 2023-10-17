//
//  Focus.swift
//  Evexia
//
//  Created by  Artem Klimov on 08.07.2021.
//

import Foundation
import UIKit.UIColor

enum Focus: String, CaseIterable, Codable, Comparable {
    case feel = "FEEL"
    case eat = "EAT"
    case connect = "CONNECT"
    case move = "MOVE"
    
    static func < (lhs: Focus, rhs: Focus) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }
    
    func sortCardByIndex() -> Int {
        var index = 0
        if let indexFocus = UserDefaults.focusCard?.sorted(by: { $0.key < $1.key }).map({ $0.value }).firstIndex(where: { $0 == self }) {
             index = indexFocus
        }
        return index
    }

    private var sortOrder: Int {
        sortCardByIndex()
    }
    
    var image_key: String {
        switch self {
        case .feel:
            return "feel"
        case .eat:
            return "eat"
        case .connect:
            return "connect"
        case .move:
            return "move"
        }
    }
    
    var title: String {
        switch self {
        case .feel:
            return "How I \nFeel"
        case .eat:
            return "How I \nEat"
        case .connect:
            return "How I \nConnect"
        case .move:
            return "How I \nMove"
        }
    }
    
    var headerTitle: String {
        switch self {
        case .feel:
            return "How I feel"
        case .eat:
            return "How I eat"
        case .connect:
            return "How I connect"
        case .move:
            return "How I move"
        }
    }
    
    var description: String {
        switch self {
        case .feel:
            return "Mindset, habits, \nidentity".localized()
        case .eat:
            return "Diet, cooking, \ngut health".localized()
        case .connect:
            return "Relaxing, sleep, \nmeditation".localized()
        case .move:
            return "Exercise, classes, \ngym ".localized()
        }
    }
    
    var tintColor: UIColor {
        switch self {
        case .feel:
            return .orange
        case .eat:
            return .eatNew
        case .connect:
            return .connectNew
        case .move:
            return .moveNew
        }
    }
    
    var sort: Int {
        switch self {
        case .feel:
            return 4
        case .eat:
            return 3
        case .connect:
            return 2
        case .move:
            return 1
        }
    }
    
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        switch value {
        case "EAT": self = .eat
        case "MOVE": self = .move
        case "CONNECT": self = .connect
        case "FEEL": self = .feel
        default:
            self = .eat
        }
    }
}
