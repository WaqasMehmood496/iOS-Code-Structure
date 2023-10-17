//
//  CommunityCellMediaType.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 14.09.2021.
//

import UIKit

enum CellMediaType: Hashable {
    case image(UIImage)
    case video(URL)
    
    init(image: UIImage) {
        self = .image(image)
    }
    
    init(urlVideo: URL) {
        self = .video(urlVideo)
    }
}

enum PostCellMediaType: Hashable {
    case image(String)
    case video(URL, LocalPost)
    
    init(image: String) {
        self = .image(image)
    }
    
    init(urlVideo: URL, post: LocalPost) {
        self = .video(urlVideo, post)
    }
}
