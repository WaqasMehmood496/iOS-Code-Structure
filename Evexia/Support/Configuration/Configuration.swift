//
//  Configuration.swift
//  Evexia
//
//  Created by Yura Yatseyko on 22.06.2021.
//

import Foundation

final class Configuration {
    
    private let config: NSDictionary
    
    init(dictionary: NSDictionary) {
        config = dictionary
    }
    
    convenience init() {
        let bundle = Bundle.main
        let configPath = bundle.path(forResource: "Configuration", ofType: "plist")!
        let config = NSDictionary(contentsOfFile: configPath)!
        
        let dict = NSMutableDictionary()
        if let configs = config[Bundle.main.infoDictionary?["Configuration"] ?? ""] as? [AnyHashable: Any] {
            dict.addEntries(from: configs)
        }
        
        self.init(dictionary: dict)
    }
}

extension Configuration {
    var environment: String {
        return config["environment"] as! String
    }
}
