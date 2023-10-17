//
//  AdditionalModels.swift
//  Evexia
//
//  Created by admin on 28.09.2021.
//

import Foundation

enum WellbeingScore {
    case low
    case medium
    case hight
    case veryHight
    
    static func getScoreLevel(for value: Int?) -> WellbeingScore? {
        guard let value = value else { return nil }
        switch value {
        case ...17:
            return .low
        case 18...20:
            return .medium
        case 21...27:
            return .hight
        case 28...:
            return .veryHight
        default:
            return nil
        }
    }
    
    var description: String {
        switch self {
        case .low:
            return """
                Your answers suggest that you may benefit from advice and support. Please click here for suggestions.
                
                On the basis of your score, you may additionally benefit from reviewing the mental health modules in your library.
                """.localized()
        case .medium:
            return """
                On the basis of your score, you may benefit from reviewing the mental health modules in your library, alongside  any additional content you may be interested in.
                
                Alternatively or additionally you may benefit from advice & support. Please click here for suggestions.
                """.localized()
        case .hight:
            return """
                Fantastic to see you are doing so well. To make even greater strides with your wellbeing, we suggest visiting your library to consume some relevant content.
                """.localized()
        case .veryHight:
            return """
                Wow, you really are feeling great. Keep creating momentum for incredible results for yourself and those around you. Check in with your daily & weekly goals to continue this fantastic feeling.
                """.localized()
        }
    }
    
    var value: String {
        switch self {
        case .low:
            return "7-17"
        case .medium:
            return "18-20"
        case .hight:
            return "21-27"
        case .veryHight:
            return "28-35"
        }
    }
}
