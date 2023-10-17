//
//  CreatePostVMType.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 07.09.2021.
//

import Combine
import UIKit

// MARK: - CreateEditPostVMOutput
typealias CreateEditPostVMOutput = AnyPublisher<CreateEditPostVCState, Never>

// MARK: - CreateEditPostVMType
protocol CreateEditPostVMType {
    var index: Int? { get set }
    var urlVideo: URL? { get set }
    var dataSource: [CellMediaType] { get set }
    var dismissPublisher: PassthroughSubject<String, Never> { get }
    var startVCState: CreateEditVCState { get }
    var post: LocalPost? { get }
    var communityUsers: CurrentValueSubject<[CommunityUser], Never> { get set }
    
    func transform(input: CreateEditPostVMInput) -> CreateEditPostVMOutput
    func createCellModel(images: [UIImage]) -> [CellMediaType]
    func searchUsers(_ text: String)
}

// MARK: - CreateEditPostVMInput
struct CreateEditPostVMInput {
    
    let appear: AnyPublisher<Void, Never>
    let addImage: AnyPublisher<[UIImage], Never>
    let addVideo: AnyPublisher<(URL, [UIImage]), Never>
    let removeImage: AnyPublisher<[UIImage], Never>
    let removeVideo: AnyPublisher<Void, Never>
    let createPost: AnyPublisher<(CreatePostRequestModel, [String]), Never>
    let uploadImage: AnyPublisher<[UIImage], Never>
    let updatePost: AnyPublisher<(CreatePostRequestModel, String, [String]), Never>
    let uploadVideo: AnyPublisher<Void, Never>
    let changeVideoIndex: AnyPublisher<Int, Never>
    let prepareModelBeforeUpload: AnyPublisher<([Attachments], String, Attachments?), Never>
}

// MARK: - CreateEditPostVCState
enum CreateEditPostVCState {
    case idle(LocalPost?)
    case successImages([Attachments])
    case failure(ServerError)
    case addImage([CellMediaType])
    case addVideo([CellMediaType])
    case successVideo(Attachments)
    case changeVideoIndex
    case removeImage([CellMediaType])
    case removeVideo
    case createPost(Post)
    case editPost(Post)
    case readyToUploadPost(CreatePostRequestModel)
  
}
