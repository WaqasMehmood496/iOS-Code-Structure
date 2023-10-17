//
//  PDCategoryDetailsRepository.swift
//  Evexia Staging
//
//  Created by Oleg Pogosian on 09.12.2021.
//

import Foundation
import Combine
import CoreImage

// MARK: - PDCategoryDetailsRepositoryProtocol
protocol PDCategoryDetailsRepositoryProtocol {
    func getPDCategoryWith(id: Int)
    func getFavoritePDCategory()
    func setFavoriteStatus(for id: String) -> AnyPublisher<FavoriteResponseModel, ServerError>
    func undoFavoriteStatus(for id: String) -> AnyPublisher<FavoriteResponseModel, ServerError>
    var errorPublisher: PassthroughSubject<ServerError, Never> { get set }
    var isFavoriteScreen: Bool { get set }
    
    var content: CurrentValueSubject<[PDCategoryDetailsModel], Never> { get set }
}

// MARK: - PDCategoryDetailsRepository
final class PDCategoryDetailsRepository {
    
    // MARK: - Properties
    private let pdNetworkProvider: PersonalDevelopmentNetworkProviderProtocol
    private let limit = 20
    private var page = 1
    private var isLastPage = false
    private var cancellables = Set<AnyCancellable>()
    private var isLoading = false
    var content = CurrentValueSubject<[PDCategoryDetailsModel], Never>([])
    var errorPublisher = PassthroughSubject<ServerError, Never>()
    var isFavoriteScreen: Bool
    
    // MARK: - Lifecycle
    init (pdNetworkProvider: PersonalDevelopmentNetworkProviderProtocol, isFavorite: Bool) {
        self.pdNetworkProvider = pdNetworkProvider
        self.isFavoriteScreen = isFavorite
    }
    
    // MARK: - Actions
    private func updatePaging(with response: PDCategoryDetailsResponseModel) {
        
        self.isLastPage = content.value.count >= response.total ?? 0
        
        if !isLastPage {
            self.page += 1
        }
    }
    
    private func updateDataSource(with models: [PDCategoryDetailsModel]) {
        var newModels = models
        
        if isFavoriteScreen {
            self.content.value.removeAll { $0.isFavorite == false }
            
            self.content.value.forEach { element in
                newModels.forEach { newElement in
                    if element.id == newElement.id {
                        guard let elementIndex = newModels.firstIndex(of: newElement) else { return }
                        
                        newModels.remove(at: elementIndex)
                    }
                }
            }
        }
        let existModels = self.content.value
        let updatedModels = existModels + newModels
        self.content.send(updatedModels)
    }
}

// MARK: - PDCategoryDetailsRepository: PDCategoryDetailsRepositoryProtocol
extension PDCategoryDetailsRepository: PDCategoryDetailsRepositoryProtocol {
    
    func getPDCategoryWith(id: Int) {
        
        guard !isLastPage && !isLoading else { return }
        isLoading = true
        
        let requestModel = BenefitRequestModel(limit: self.limit, counter: self.page)
        
        return pdNetworkProvider.getAllPDCategories(id: id, requestModel: requestModel)
            .sink(receiveCompletion: { [weak self] _ in
                self?.isLoading = false
            },
                  receiveValue: { [weak self] response in
                self?.updatePaging(with: response)
                self?.updateDataSource(with: response.data)
            }).store(in: &cancellables)
    }
    
    func getFavoritePDCategory() {
        
        guard !isLastPage && !isLoading else { return }
        isLoading = true
        
        let requestModel = BenefitRequestModel(limit: self.limit, counter: self.page)
        
        return pdNetworkProvider.getFavotitePDCategory(requestModel: requestModel)
            .sink(receiveCompletion: { [weak self] _ in
                self?.isLoading = false
            },
                  receiveValue: { [weak self] response in
                self?.updatePaging(with: response)
                self?.updateDataSource(with: response.data)
            }).store(in: &cancellables)
        
    }
    
    func setFavoriteStatus(for id: String) -> AnyPublisher<FavoriteResponseModel, ServerError> {
        return pdNetworkProvider.setFavoriteStatus(for: id)
    }
    
    func undoFavoriteStatus(for id: String) -> AnyPublisher<FavoriteResponseModel, ServerError> {
        if isFavoriteScreen {
            self.page = 1
        }
        return pdNetworkProvider.undoFavoriteStatus(for: id)
    }
}
