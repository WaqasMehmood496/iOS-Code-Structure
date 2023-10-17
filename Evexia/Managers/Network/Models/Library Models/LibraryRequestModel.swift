//
//  LibraryRequestModel.swift
//  Evexia
//
//  Created by admin on 05.10.2021.
//

import Foundation

struct LibraryRequestModel: Encodable {
    var type: Focus
    var fileType: ContentType
    var counter: Int
    var limit: Int
}
