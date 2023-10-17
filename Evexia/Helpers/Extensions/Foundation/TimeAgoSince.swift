//
//  TimeAgoSince.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 11.09.2021.
//

import Foundation

enum TimaTypeAgo {
    case comment
    case post
}

extension Double {
    func timeAgoSince(type: TimaTypeAgo) -> String {
        let date = Date(timeIntervalSince1970: self)

        let calendar = Calendar.current
        let now = Date()
        let unitFlags: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfYear, .month, .year]
        let components = (calendar as NSCalendar).components(unitFlags, from: date, to: now, options: [])
        
        if let year = components.year, year >= 2 {
            return type == .post ? "\(year) years ago" : "\(year)y"
        }
        
        if let year = components.year, year >= 1 {
            return "Last year"
        }
        
        if let month = components.month, month >= 2 {
            return type == .post ? "\(month) months ago" : "\(month)m"
        }
        
        if let month = components.month, month >= 1 {
            return "Last month"
        }
        
        if let week = components.weekOfYear, week >= 2 {
            return type == .post ? "\(week) weeks ago" : "\(week)w"
        }
        
        if let week = components.weekOfYear, week >= 1 {
            return "Last week"
        }
        
        if let day = components.day, day >= 2 {
            return type == .post ? "\(day) days ago" : "\(day)d"
        }
        
        if let day = components.day, day >= 1 {
            return type == .post ? "Yesterday" : "\(day)d"
        }
        
        if let hour = components.hour, hour >= 2 {
            return type == .post ? "\(hour) hours ago" : "\(hour)h"
        }
        
        if let hour = components.hour, hour >= 1 {
            return type == .post ? "An hour ago" : "\(hour)h"
        }
        
        if let minute = components.minute, minute >= 2 {
            return type == .post ? "\(minute) minutes ago" : "\(minute)m"
        }
        
        if let minute = components.minute, minute >= 1 {
            return type == .post ? "A minute ago" : "\(minute)m"
        }
        
        if let second = components.second, second >= 3 {
            return type == .post ? "\(second) seconds ago" : "\(second)s"
        }
        
        return "Just now"
        
    }
}
