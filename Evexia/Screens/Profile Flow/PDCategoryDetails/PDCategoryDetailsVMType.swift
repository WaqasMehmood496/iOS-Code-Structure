//
//  PDCategoryDetailsVMType.swift
//  Evexia Staging
//
//  Created by Oleg Pogosian on 09.12.2021.
//

import Foundation
import Combine

typealias PDCategoryDetailsVMOutput = AnyPublisher<PDCategoryDetailsVCState, Never>

protocol PDCategoryDetailsVMType {
    
    var content: CurrentValueSubject<[PDCategoryDetailsModel], Never> { get set }
    var screenTitle: String { get }
    
    func applyNavigation(for: PDCategoryDetailsModel)
    func changeFavorite(for model: PDCategoryDetailsModel)
    func getMoreContent()
}

struct PDCategoryDetailsVMInput {
    let appear: AnyPublisher<Void, Never>
}

enum PDCategoryDetailsVCState {
    case idle
    case loading
    case success([PDCategoryDetailsModel])
    case failure(ServerError)
}
