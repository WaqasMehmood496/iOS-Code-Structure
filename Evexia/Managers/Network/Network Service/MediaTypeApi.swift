//
//  MediaTypeApi.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 15.09.2021.
//

import Foundation

enum HTTPHeadersKey: String {
    case contentType = "Content-Type"
    case authorization = "Authorization"
    case contentDisposition = "Content-Disposition"
    case contentLength = "Content-Length"
    case applicationId = "X-Parse-Application-Id"
    case restApiKey = "X-Parse-REST-API-Key"
}

enum MediaType {
    case video
    case image
}
