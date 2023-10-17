//
//  CommentsListVMType.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 26.09.2021.
//

import Foundation
import Combine

typealias CommentsListVMOutput = AnyPublisher<CommentsListVCState, Never>

// MARK: - CommentsListVMType
protocol CommentsListVMType {
    var post: LocalPost { get }
    var viewType: PostViewType { get }
    var isPagination: Bool { get set }
    var isReadyToPagination: Bool { get set }
    var communityUsers: CurrentValueSubject<[CommunityUser], Never> { get set }
    
    func transform(input: CommentsListVMInput) -> CommentsListVMOutput
    func openURL(url: URL, dismissSocialWebView: PassthroughSubject<Int?, Never>)
    func searchUsers(_ text: String)
}

// MARK: - CommentsListVMInput
struct CommentsListVMInput {
    let appear: AnyPublisher<Void, Never>
    let loadComments: AnyPublisher<Void, Never>
    let addReply: AnyPublisher<(String, String, ReplyToModel, [String]), Never>
    let createComment: AnyPublisher<(String, [String]), Never>
    let addRemoveLikePublisher: AnyPublisher<String, Never>
    let updateComments: AnyPublisher<Void, Never>
}

// MARK: - CommentsListVCState
enum CommentsListVCState {
    case idle(LocalPost)
    case failure(ServerError)
    case addRemoveLike
    case somePage([CommentsCellType])
    case lastPage([CommentsCellType])
    case addComment([CommentsCellType])
    case addReply([CommentsCellType], String)
}
