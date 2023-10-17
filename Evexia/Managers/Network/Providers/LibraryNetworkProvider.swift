//
//  LibraryProvider.swift
//  Evexia
//
//  Created by admin on 04.10.2021.
//

import Foundation
import Combine

protocol LibraryNetworkProviderProtocol {
    
    func getLibraryContent(with model: LibraryRequestModel) -> AnyPublisher<LibraryResponseModel, ServerError>
    
    func incrementViews(for id: String) -> AnyPublisher<BaseResponse, ServerError>
    
    func setFavoriteStatus(for id: String) -> AnyPublisher<FavoriteResponseModel, ServerError>
    
    func undoFavoriteStatus(for id: String) -> AnyPublisher<FavoriteResponseModel, ServerError>
    
    func getLibraryFavoriteContent(with model: LibraryRequestModel) -> AnyPublisher<LibraryResponseModel, ServerError>
}

final class LibraryNetworkProvider: NetworkProvider, LibraryNetworkProviderProtocol {
    
    func getLibraryContent(with model: LibraryRequestModel) -> AnyPublisher<LibraryResponseModel, ServerError> {
        return request(.getLibrary(model: model)).eraseToAnyPublisher()
    }
    
    func incrementViews(for id: String) -> AnyPublisher<BaseResponse, ServerError> {
        return request(.watched(id: id))
    }
    
    func setFavoriteStatus(for id: String) -> AnyPublisher<FavoriteResponseModel, ServerError> {
        return request(.favorites(id: id))
    }
    
    func undoFavoriteStatus(for id: String) -> AnyPublisher<FavoriteResponseModel, ServerError> {
        return request(.undoFavorites(id: id))
    }
    
    func getLibraryFavoriteContent(with model: LibraryRequestModel) -> AnyPublisher<LibraryResponseModel, ServerError> {
        return request(.getFavorites(model: model)).eraseToAnyPublisher()
    }
}
