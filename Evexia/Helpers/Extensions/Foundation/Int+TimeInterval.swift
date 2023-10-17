//
//  Int+TimeInterval.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 28.08.2021.
//

import Foundation

// MARK: Int+TimeInterval for network

extension Int {

    var second: TimeInterval {
        return Double(self)
    }
    
    var seconds: TimeInterval {
        return Double(self)
    }
    
    var minute: TimeInterval {
        return Double(self) * 60
    }
    
    var minutes: TimeInterval {
        return Double(self) * 60
    }
    
    var hour: TimeInterval {
        return Double(self) * 3_600
    }
    
    var hours: TimeInterval {
        return Double(self) * 3_600
    }
    
    var day: TimeInterval {
        return Double(self) * 3_600 * 24
    }
    
    var days: TimeInterval {
        return Double(self) * 3_600 * 24
    }
}
