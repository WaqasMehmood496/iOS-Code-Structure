//
//  CreateCommentVMType.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 20.09.2021.
//

import Combine

// MARK: - CreateCommentVMOutput
typealias CreateCommentVMOutput = AnyPublisher<CreateCommentVCState, Never>

// MARK: - CreateCommentVMType
protocol CreateCommentVMType {
    var viewType: PostViewType { get }
    var communityUsers: CurrentValueSubject<[CommunityUser], Never> { get set }

    func transform(input: CreateCommentVMInput) -> CreateCommentVMOutput
    func searchUsers(_ text: String)
}

// MARK: - CreateCommentVMInput
struct CreateCommentVMInput {
    let appear: AnyPublisher<Void, Never>
    let createComment: AnyPublisher<(String, [String]), Never>
}

// MARK: - CreateCommentVCState
enum CreateCommentVCState {
    case idle(LocalPost)
    case failure(ServerError)
    case createComment(CommentResponseModel)
}
