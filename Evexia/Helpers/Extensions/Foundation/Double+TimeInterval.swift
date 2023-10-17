//
//  Double+TimeInterval.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 28.08.2021.
//

import Foundation

// MARK: Double+TimeInterval for Network

extension Double {
   
    var second: TimeInterval {
        return self
    }
    
    var seconds: TimeInterval {
        return self
    }
    
    var minute: TimeInterval {
        return self * 60
    }
    
    var minutes: TimeInterval {
        return self * 60
    }
    
    var hour: TimeInterval {
        return self * 3_600
    }
    
    var hours: TimeInterval {
        return self * 3_600
    }
    
    var day: TimeInterval {
        return self * 3_600 * 24
    }
    
    var days: TimeInterval {
        return self * 3_600 * 24
    }
}
