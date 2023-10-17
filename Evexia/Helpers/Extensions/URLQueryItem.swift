//
//  URLQueryItem.swift
//  Evexia
//
//  Created by  Artem Klimov on 29.06.2021.
//

import Foundation

// MARK: - Encodable
extension Encodable {
    
    var dictionary: [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else { return [:] }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] } ?? [:]
    }
}

extension Decodable {
    init?(dictionary: [String: Any]) {
        self = try! JSONDecoder().decode(Self.self, from: JSONSerialization.data(withJSONObject: dictionary))
    }
}

// MARK: - Collection
extension Collection {
    func enumeratedArray() -> [(offset: Int, element: Self.Element)] {
        return Array(self.enumerated())
    }
}

public extension URL {
    
    var queryParameters: [String: String]? {
        let comp = self.pathComponents
        let dict = [comp[comp.count - 1]: ""]
        
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        let params = queryItems.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        }
        let parameters = params.reduce(into: dict) { r, e in r[e.0] = e.1 }
        return parameters
        
    }
    
    var paths: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return nil
        }
        var pathComponents = components.path.components(separatedBy: "/")
        pathComponents.removeFirst()
        
        let paths = pathComponents.reduce(into: [String: String]()) { result, item in
            result[item] = item
        }
        return paths
    }
}
