//
//  PersonalDevelopmentProvider.swift
//  Evexia Staging
//
//  Created by Oleg Pogosian on 07.12.2021.
//

import Foundation
import Combine

protocol PersonalDevelopmentNetworkProviderProtocol {
    
    /** Get All Personal Development Categories */
    func getAllPersonalDevelopmentCategories() -> AnyPublisher<PersonalDevCategory, ServerError>
    
    func getAllPDCategories(id: Int, requestModel: BenefitRequestModel) -> AnyPublisher<PDCategoryDetailsResponseModel, ServerError>
    
    func getFavotitePDCategory(requestModel: BenefitRequestModel) -> AnyPublisher<PDCategoryDetailsResponseModel, ServerError>
    
    func setFavoriteStatus(for id: String) -> AnyPublisher<FavoriteResponseModel, ServerError>
    
    func undoFavoriteStatus(for id: String) -> AnyPublisher<FavoriteResponseModel, ServerError>
    
}

class PersonalDevelopmentNetworkProvider: NetworkProvider, PersonalDevelopmentNetworkProviderProtocol {
    
    func getAllPersonalDevelopmentCategories() -> AnyPublisher<PersonalDevCategory, ServerError> {
        return request(.getPersonalDevelopmentCategories).eraseToAnyPublisher()
    }
    
    func getAllPDCategories(id: Int, requestModel: BenefitRequestModel) -> AnyPublisher<PDCategoryDetailsResponseModel, ServerError> {
        return request(.getPersonalDevelopmentCategory(id: id, model: requestModel)).eraseToAnyPublisher()
    }
    
    func getFavotitePDCategory(requestModel: BenefitRequestModel) -> AnyPublisher<PDCategoryDetailsResponseModel, ServerError> {
        request(.getFavoritePDCategory(model: requestModel)).eraseToAnyPublisher()
    }
    
    func setFavoriteStatus(for id: String) -> AnyPublisher<FavoriteResponseModel, ServerError> {
        return request(.makePDCategoryFavorite(id: id))
    }
    
    func undoFavoriteStatus(for id: String) -> AnyPublisher<FavoriteResponseModel, ServerError> {
        return request(.removePDCategoryFromFavorites(id: id))
    }
    
}

