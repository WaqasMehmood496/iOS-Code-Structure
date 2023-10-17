//
//  LibraryRepository.swift
//  Evexia
//
//  Created by admin on 05.10.2021.
//

import Foundation
import Combine
import HCVimeoVideoExtractor

protocol LibraryRepositoryProtocol {
    func getContent(contentType: ContentType, category: Focus, reload: Bool)
    func getFavoriteContent(contentType: ContentType, category: Focus, reload: Bool)
    func getMainVideo(for category: Focus) -> AnyPublisher<ContentModel?, ServerError>
    func incrementViews(for id: String)
    func retriveVimeoVideo(url: URL) -> PassthroughSubject<URL, Error>
    func setFavoriteStatus(for id: String) -> AnyPublisher<FavoriteResponseModel, ServerError>
    func undoFavoriteStatus(for id: String) -> AnyPublisher<FavoriteResponseModel, ServerError>
   
    var content: CurrentValueSubject<[ContentModel], Never> { get set }
}

class LibraryRepository {
    
    var content = CurrentValueSubject<[ContentModel], Never>([])
    
    private let limit = 20
    private var page = 1
    private var isLastPage = false
    private let libraryNetworkProvider: LibraryNetworkProviderProtocol
    private var cancellables = Set<AnyCancellable>()
    private var isLoading = false

    init(libraryNetworkProvider: LibraryNetworkProviderProtocol) {
        self.libraryNetworkProvider = libraryNetworkProvider
    }
    
    private func updatePaging(with response: LibraryResponseModel) {
        self.isLastPage = response.isLastPage
        if !response.isLastPage {
            self.page += 1
        }
    }
    
    private func updateDataSource(with models: [ContentModel], reload: Bool) {
        let existModels = reload ? [] : self.content.value
        let updatedModels = existModels + models
        self.content.send(updatedModels)
    }
}

extension LibraryRepository: LibraryRepositoryProtocol {
    
    func getMainVideo(for category: Focus) -> AnyPublisher<ContentModel?, ServerError> {
        let requestModel = LibraryRequestModel(type: category, fileType: .video, counter: 1, limit: 1)
        
        return self.libraryNetworkProvider.getLibraryContent(with: requestModel)
            .map { response in
                return response.data.first
            }
            .eraseToAnyPublisher()
    }
    
    func getContent(contentType: ContentType, category: Focus, reload: Bool) {
        if reload {
            page = 1
            cancellables.forEach { $0.cancel() }
            cancellables.removeAll()
        } else {
            guard !isLastPage && !isLoading else { return }
            isLoading = true
        }
        
        let requestModel = LibraryRequestModel(type: category, fileType: contentType, counter: page, limit: limit)
        
        self.libraryNetworkProvider.getLibraryContent(with: requestModel)
            .sink(receiveCompletion: { [weak self] _ in
                self?.isLoading = false
            }, receiveValue: { [weak self] response in
                self?.updatePaging(with: response)
                self?.updateDataSource(with: response.data, reload: reload)
            }).store(in: &cancellables)
    }
    
    func getFavoriteContent(contentType: ContentType, category: Focus, reload: Bool) {
        if reload {
            page = 1
            cancellables.forEach { $0.cancel() }
            cancellables.removeAll()
        } else {
            guard !isLastPage && !isLoading else { return }
            isLoading = true
        }

        self.page = reload ? 1 : self.page
        let requestModel = LibraryRequestModel(type: category, fileType: contentType, counter: page, limit: self.limit)
        
        return self.libraryNetworkProvider.getLibraryFavoriteContent(with: requestModel)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] response in
                self?.updatePaging(with: response)
                self?.updateDataSource(with: response.data, reload: reload)
            }).store(in: &cancellables)
    }
    
    func incrementViews(for id: String) {
        self.libraryNetworkProvider.incrementViews(for: id)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    func retriveVimeoVideo(url: URL) -> PassthroughSubject<URL, Error> {
        let publisher = PassthroughSubject<URL, Error>()
        
        HCVimeoVideoExtractor.fetchVideoURLFrom(url: url, completion: { (video: HCVimeoVideo?, error: Error?) -> Void in
            if let err = error {
                publisher.send(completion: .failure(err))
                return
            }
            
            guard let vid = video else {
                publisher.send(completion: .failure(ServerError(errorCode: .networkError)))
                return
            }
            
            if let videoURL = vid.videoURL[.quality720p] {
                publisher.send(videoURL)
                publisher.send(completion: .finished)
            }
        })
        return publisher
    }
    
    func setFavoriteStatus(for id: String) -> AnyPublisher<FavoriteResponseModel, ServerError> {
        return libraryNetworkProvider.setFavoriteStatus(for: id)
    }
    
    func undoFavoriteStatus(for id: String) -> AnyPublisher<FavoriteResponseModel, ServerError> {
        return libraryNetworkProvider.undoFavoriteStatus(for: id)
    }
}
