//
//  DatabaseError.swift
//  Evexia
//
//  Created by  Artem Klimov on 01.07.2021.
//

import Foundation

enum DatabaseError: Error {
    case saveFailed(String)
}
