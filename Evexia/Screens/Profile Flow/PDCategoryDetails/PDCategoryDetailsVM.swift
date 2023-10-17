//
//  PDCategoryDetailsVM.swift
//  Evexia Staging
//
//  Created by Oleg Pogosian on 09.12.2021.
//

import Foundation
import Combine

class PDCategoryDetailsVM: PDCategoryDetailsVMType {
    
    // MARK: - Properties
    var content = CurrentValueSubject<[PDCategoryDetailsModel], Never>([])
    var screenTitle: String
    private var cancellables: [AnyCancellable] = []
    private let repository: PDCategoryDetailsRepositoryProtocol
    private let router: PDCategoryDetailsRouter
    private var id: Int
    
    // MARK: - Lifecycle
    init(repository: PDCategoryDetailsRepositoryProtocol, router: PDCategoryDetailsRouter, id: Int, title: String) {
        self.repository = repository
        self.router = router
        self.id = id
        self.screenTitle = title
        
        self.repository.content
            .assign(to: \.value, on: content)
            .store(in: &cancellables)
        self.getMoreContent()
    }
    
    func changeFavorite(for model: PDCategoryDetailsModel) {
        
        if model.isFavorite {
            repository.setFavoriteStatus(for: model.id)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self = self else {
                        return }
                    
                    switch completion {
                    case .finished:
                        break
                    case .failure:
                        self.undoFavorite(for: model)
                    }
                }, receiveValue: { _ in
                    return
                }).store(in: &cancellables)
        } else {
            repository.undoFavoriteStatus(for: model.id)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self = self else {
                        return }
                    
                    switch completion {
                    case .finished:
                        if self.id == -1 {
                            if let elementIndex = self.content.value.firstIndex(of: model) {
                                self.content.value.remove(at: elementIndex)
                                self.content.send(self.content.value)
                            }
                        }
                        break
                    case .failure:
                        self.undoFavorite(for: model)
                    }
                }, receiveValue: { _ in
                    return
                }).store(in: &cancellables)
        }
        
    }
    
    func getMoreContent() {
        if self.id == -1 {
            self.repository.getFavoritePDCategory()
        } else {
            self.repository.getPDCategoryWith(id: self.id)
        }
    }
    
    private func undoFavorite(for model: PDCategoryDetailsModel) {
        guard let undoModel = self.content.value.first(where: { $0.id == model.id }) else { return }
        
        undoModel.isFavorite.toggle()
        self.content.send(self.content.value)
    }
    
    // MARK: - Actions
    func applyNavigation(for model: PDCategoryDetailsModel) {
        self.router.openBrowser(url: model.fileURL)
    }
}
