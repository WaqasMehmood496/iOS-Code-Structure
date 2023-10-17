//
//  СommunityVMType.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 03.09.2021.
//

import Combine

// MARK: - CreateEditVCState
enum CreateEditVCState {
    case create
    case edit
}

// MARK: - CommunityVMOtput
typealias CommunityVMOtput = AnyPublisher<CommunityVCState, Never>

// MARK: - CommunityVMType
protocol CommunityVMType {
    var isPagination: Bool { get set }
    var isReadyToPagination: Bool { get set }
    var models: [LocalPost] { get }
    
    func transform(input: CommunityVMInput) -> CommunityVMOtput
    func presentCreateEditVC(state: CreateEditVCState, post: LocalPost?, dismissPublisher: PassthroughSubject<String, Never>)
    func presentLikesSharedVC(type: LikesSharedStartVCType, postId: String)
    func navigationToProfile()
    func navigationToCreateComment(post: LocalPost, addCommentPublisher: PassthroughSubject<LocalPost, Never>, viewType: PostViewType)
    func navigateToCommentsList(post: LocalPost, addRemoveLikePublisher: PassthroughSubject<String, Never>, addCommentPublisher: PassthroughSubject<LocalPost, Never>, viewType: PostViewType)
}

// MARK: - CommunityVMInput
struct CommunityVMInput {
    
    let appear: AnyPublisher<Void, Never>
    let updatePosts: AnyPublisher<Void, Never>
    let deletePost: AnyPublisher<String, Never>
    let createPost: AnyPublisher<String, Never>
    let dismissCreateAndUpdatePublisher: AnyPublisher<String, Never>
    let addRemoveLikePublisher: AnyPublisher<String, Never>
    let addCommentPublisher: AnyPublisher<LocalPost, Never>
}

// MARK: - CommunityVCState
enum CommunityVCState {
    case idle
    case loading
    case updateCommunity([CommunityCellContent])
    case somePage([CommunityCellContent])
    case lastPage([CommunityCellContent])
    case failure(ServerError)
    case deletePost([CommunityCellContent])
    case creatStaticPost(Post)
    case addSocialAction([CommunityCellContent], SocialAction)
}
