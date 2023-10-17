//
//  CreatePostVM.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 07.09.2021.
//

import Combine
import Foundation
import UIKit

// MARK: - CreateEditPostVM
class CreateEditPostVM: CreateEditPostVMType {
    
    // MARK: - Properties
    let startVCState: CreateEditVCState
    let post: LocalPost?
    let dismissPublisher: PassthroughSubject<String, Never>
    var dataSource: [CellMediaType] = []
    var index: Int?
    var urlVideo: URL?
    var communityUsers = CurrentValueSubject<[CommunityUser], Never>([])
    var companyUsers = [CommunityUser]()
    private var cancellables = Set<AnyCancellable>()

    private let repository: CreateEditPostRepositoryProtocol
    private let router: CreateEditPostNavigation
    private var attachments: [Attachments] = []
    
    // MARK: - Init
    init(
        repository: CreateEditPostRepositoryProtocol,
        router: CreateEditPostNavigation,
        startVCState: CreateEditVCState,
        post: LocalPost?,
        dismissPublisher: PassthroughSubject<String, Never>
    ) {
        self.repository = repository
        self.router = router
        self.startVCState = startVCState
        self.post = post
        self.dismissPublisher = dismissPublisher
        self.getAllUsers()

    }
    
    func getAllUsers() {
        self.repository.searchUsers(text: "")
            .sink(receiveCompletion: { _ in },
            receiveValue: { [weak self] users in
                self?.companyUsers = users
            }).store(in: &self.cancellables)
    }
    
    func searchUsers(_ text: String) {
        self.repository.searchUsers(text: text)
            .sink(receiveCompletion: { _ in
                
            },
            receiveValue: { [weak self] users in
                
                self?.communityUsers.send(users)
            }).store(in: &self.cancellables)
    }
    
    func transform(input: CreateEditPostVMInput) -> CreateEditPostVMOutput {
        
        let idle = input.appear
            .map { [weak self] _ -> CreateEditPostVCState in
                return .idle(self?.post)
            }.eraseToAnyPublisher()
        
        let addImage = input.addImage
            .map { [unowned self] images -> CreateEditPostVCState in
                return .addImage(self.createCellModel(images: images))
            }.eraseToAnyPublisher()
        
        let addVideo = input.addVideo
            .map { [unowned self] urlVideo, images -> CreateEditPostVCState in
                self.urlVideo = urlVideo
                return .addVideo(self.createCellModel(images: images))
            }.eraseToAnyPublisher()
        
        let removeImage = input.removeImage
            .map { [unowned self] images -> CreateEditPostVCState in
                return .removeImage(self.createCellModel(images: images))
            }.eraseToAnyPublisher()
        
        let removeVideo = input.removeVideo
            .map { [weak self] _ -> CreateEditPostVCState in
                self?.urlVideo = nil
                self?.index = nil
                return .removeVideo
            }.eraseToAnyPublisher()
        
        let createPost = input.createPost
            .flatMap({ [unowned self] model, tags -> AnyPublisher<Result<Post, ServerError>, Never> in
                let users = tags.compactMap { tag in
                    self.companyUsers.first(where: { $0.username == tag })
                }
                let ids = users.map { $0.id }
                var post = model
                post.employees = ids
                return self.repository.createPost(model: post)
            })
            .receive(on: DispatchQueue.main)
            .map({ result -> CreateEditPostVCState in
                switch result {
                case let .failure(error):
                    return .failure(error)
                case let .success(post):
                    return .createPost(post)
                }
            }).eraseToAnyPublisher()
        
        let editPost = input.updatePost
            .flatMap({ [unowned self] attachment, postId, tags -> AnyPublisher<Result<Post, ServerError>, Never> in
                let users = tags.compactMap { tag in
                    self.companyUsers.first(where: { $0.username == tag })
                }
                let ids = users.map { $0.id }
                
                return self.repository.editPost(editPost: attachment, postId: postId, employees: ids)
            })
            .receive(on: DispatchQueue.main)
            .map({ result -> CreateEditPostVCState in
                switch result {
                case let .failure(error):
                    return .failure(error)
                case let .success(model):
                    return .editPost(model)
                }
            })
            .eraseToAnyPublisher()
        
        let uploadImage = input.uploadImage
            .flatMap({ [unowned self] images -> AnyPublisher<Result<[Attachments], ServerError>, Never> in
                let datas = images.compactMap { $0.jpegData(compressionQuality: 1.0) }
                
                return self.repository.uploadImage(data: datas)
            })
            .receive(on: DispatchQueue.main)
            .map({ result -> CreateEditPostVCState in
                switch result {
                case let .failure(error):
                    return .failure(error)
                case let .success(attachment):
                    return .successImages(attachment)
                }
            }).eraseToAnyPublisher()
        
        let uploadVideo = input.uploadVideo
            .flatMap({ [unowned self] _ -> AnyPublisher<Result<Attachments, ServerError>, Never> in
                guard
                    let url = urlVideo, let movieData = try? Data(contentsOf: url)
                else { return .just(.failure(.init(errorCode: .jsonParseError))) }
                
                return self.repository.uploadVideo(data: movieData)
            })
            .receive(on: DispatchQueue.main)
            .map({ result -> CreateEditPostVCState in
                switch result {
                case let .failure(error):
                    return .failure(error)
                case let .success(attachment):
                    return .successVideo(attachment)
                }
            })
            .eraseToAnyPublisher()
        
        let changeVideoIndex = input.changeVideoIndex
            .map { index -> CreateEditPostVCState in
                self.index = index
                return .changeVideoIndex
            }.eraseToAnyPublisher()
        
        let readyToUploadPost = input.prepareModelBeforeUpload
            .map { imageAttachments, textContent, videoAttachment -> CreateEditPostVCState in
                let model = CreatePostRequestModel(attachments: imageAttachments, content: textContent, video: videoAttachment)
                
                return .readyToUploadPost(model)
            }.eraseToAnyPublisher()
        
        return Publishers.MergeMany(idle, addImage, addVideo, removeImage, removeVideo, createPost, uploadImage, editPost, uploadVideo, changeVideoIndex, readyToUploadPost).eraseToAnyPublisher()
    }
    
    func createCellModel(images: [UIImage]) -> [CellMediaType] {
        dataSource = images.compactMap(CellMediaType.init)
        
        if let index = index, let urlVideo = urlVideo {
            dataSource.insert(.init(urlVideo: urlVideo), at: index)
        } 
        
        return dataSource
    }
}
