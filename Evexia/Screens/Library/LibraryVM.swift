//
//  LibraryVM.swift
//  Evexia
//
//  Created by admin on 05.10.2021.
//

import Foundation
import Combine
import AVKit
import DeveloperToolsSupport

class LibraryVM {
    
    // MARK: - Properties
    internal var contentType = CurrentValueSubject<ContentType, Never>(.video)
    internal var category = CurrentValueSubject<Focus, Never>(.feel)
    internal var content = CurrentValueSubject<[ContentModel], Never>([])
    internal var mainVideoModel = CurrentValueSubject<ContentModel?, Never>(nil)
    internal var errorPublisher = PassthroughSubject<ServerError, Never>()
    internal var refreshing = PassthroughSubject<Void, Never>()
    internal var categoryDataSource = CurrentValueSubject<[Focus], Never>(Focus.allCases)
    internal var isOnFavoriteFilter = CurrentValueSubject<Bool, Never>(false)
    
    private var cancellables = Set<AnyCancellable>()
    private var requestCancellasbles = Set<AnyCancellable>()
    private var router: LibraryRouter
    private var repository: LibraryRepositoryProtocol
    
    init(repository: LibraryRepositoryProtocol, router: LibraryRouter) {
        self.repository = repository
        self.router = router
        self.binding()
    }
    
    func bindOnCategorise() {
        
        Publishers.CombineLatest3(contentType, category, isOnFavoriteFilter)
            .sink(receiveValue: { [weak self] contentType, category, isOnFavorite in
                if isOnFavorite {
                    self?.getFavoriteContent(contentType: contentType, category: category, reload: true)
                } else {
                    self?.getContent(contentType: contentType, category: category, reload: true)
                }
            }).store(in: &cancellables)
        
        self.category
            .sink(receiveValue: { [weak self] category in
                self?.getMainVideo(for: category)
            }).store(in: &cancellables)
    }
    
    private func getMainVideo(for category: Focus) {
        
        self.repository.getMainVideo(for: category)
            .sink( receiveCompletion: { _ in },
                   receiveValue: { [weak self] model in
                self?.mainVideoModel.send(model)
            }).store(in: &cancellables)
    }
    
    func getMoreContent() {
        if self.isOnFavoriteFilter.value {
            self.getFavoriteContent(contentType: self.contentType.value, category: category.value, reload: false)
        } else {
            self.getContent(contentType: self.contentType.value, category: category.value, reload: false)
        }
    }
    
    func showVideo(_ model: ContentModel) {
        guard let url = URL(string: model.fileUrl) else { return }
        if url.absoluteString.contains("vimeo") {
            self.repository.retriveVimeoVideo(url: url)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in },
                      receiveValue: { [weak self] vimeoURL in
                    self?.preparePlayer(for: vimeoURL)
                }).store(in: &cancellables)
            
        } else if !url.absoluteString.contains(".mp4") {
            self.router.showPDF(url: model.fileUrl)
        } else {
            self.preparePlayer(for: url)
        }
    }
    
    private func binding() {
        self.repository.content
            .assign(to: \.value, on: content)
            .store(in: &cancellables)
        
        self.refreshing
            .sink(receiveValue: { [weak self] in
                guard let self = self else { return }
                if self.isOnFavoriteFilter.value {
                    self.getFavoriteContent(contentType: self.contentType.value, category: self.category.value, reload: true)
                } else {
                    self.getContent(contentType: self.contentType.value, category: self.category.value, reload: true)
                }
                self.getMainVideo(for: self.category.value)
            }).store(in: &cancellables)
    }
    
    private func getContent(contentType: ContentType, category: Focus, reload: Bool) {
        self.repository.getContent(contentType: contentType, category: category, reload: reload)
    }
    
    private func getFavoriteContent(contentType: ContentType, category: Focus, reload: Bool) {
        self.repository.getFavoriteContent(contentType: contentType, category: category, reload: reload)
    }
    
    private func preparePlayer(for url: URL) {
        
        let player = AVPlayer(url: url)
        let controller = AVPlayerViewController()
        controller.player = player
        self.router.showVideo(controller: controller, completion: {
            player.play()
        })
    }
    
    func changeMainVideoFavorite() {
        guard let model = mainVideoModel.value else { return }
        guard let undoModel = self.content.value.first(where: { $0.id == model.id }) else {
            self.changeFavorite(for: model)
            return
        }
        undoModel.isFavorite.toggle()
        self.content.send(self.content.value)
        self.changeFavorite(for: model)
    }
    
    func changeFavorite(for model: ContentModel) {
        
        if let mainVideo = mainVideoModel.value, model.id == mainVideo.id {
            mainVideo.isFavorite.toggle()
            mainVideoModel.send(mainVideo)
        }
        
        if model.isFavorite {
            repository.setFavoriteStatus(for: model.id)
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure:
                        self?.undoFavorite(for: model)
                    }
                }, receiveValue: { _ in
                    return
                }).store(in: &cancellables)
        } else {
            repository.undoFavoriteStatus(for: model.id)
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure:
                        self?.undoFavorite(for: model)
                    }
                }, receiveValue: { [weak self] _ in
                    self?.removeFromFavorite(for: model)
                }).store(in: &cancellables)
        }
        
    }
    
    private func undoFavorite(for model: ContentModel) {
            guard let undoModel = self.content.value.first(where: { $0.id == model.id }) else { return }
            undoModel.isFavorite.toggle()
            self.content.send(self.content.value)
    }
    
    func removeFromFavorite(for model: ContentModel) {
        if isOnFavoriteFilter.value {
        guard let undoModel = self.content.value.first(where: { $0.id == model.id }) else { return }
        let content = self.content.value.filter({ $0.id != undoModel.id })
        self.content.send(content)
        }
    }
    
    // Navigation
    func applyNavigation(for model: ContentModel) {
        switch model.fileType {
        case .video:
            self.showVideo(model)
        case .audio:
            self.router.openBrowser(url: model.fileUrl)
        case .pdf:
            self.router.showPDF(url: model.fileUrl)
        }
        
        self.repository.incrementViews(for: model.id)
    }
}
