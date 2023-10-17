//
//  FBToken.swift
//  Evexia
//
//  Created by  Artem Klimov on 07.07.2021.
//

import Foundation

class FBToken: Codable {
    
    var fbToken: String
    
    // - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case fbToken
    }
    
    init(fbToken: String = "") {
        self.fbToken = fbToken
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fbToken, forKey: .fbToken)
    }
}
