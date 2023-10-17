//
//  CommunityNetworkProvidr.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 03.09.2021.
//

import Foundation
import Combine

protocol CommunityNetworkProviderProtocol {
    
    /** Upload image when create/edit post t in Community */
    func uploadImage(data: [Data]) -> AnyPublisher<[Attachments], ServerError>
    
    /** Upload video when create/edit post t in Community */
    func uploadVideo(data: Data) -> AnyPublisher<Attachments, ServerError>
    
    /** Create New Post in Community */
    func createPost(model: CreatePostRequestModel) -> AnyPublisher<Post, ServerError>
    
    /** Create New Static Post in Community */
    func createStaticPost(steps: String) -> AnyPublisher<Post, ServerError>
    
    /** Get Posts  in Community  */
    func getPosts(model: CommunityRequestModel) -> AnyPublisher<Community, ServerError>
    
    /** Delete post by id  in Community  */
    func deletePost(postId: String) -> AnyPublisher<BaseResponse, ServerError>
    
    /** Edit post by id  in Community  */
    func editPost(model: CreatePostRequestModel, postId: String, employees: [String]) -> AnyPublisher<Post, ServerError>
    
    /** Get shares by post id in Community  */
    func getShares(postId: String) -> AnyPublisher<[LikeAndShares], ServerError>
    
    /** Add shares by post id in Community  */
    func addShares() -> AnyPublisher<Post, ServerError>
    
    /** Get likes by post id in Community  */
    func getLikes(postId: String) -> AnyPublisher<[LikeAndShares], ServerError>
    
    /** Add / Remove like to post by post id in Community  */
    func addRemoveLike(postId: String) -> AnyPublisher<LikePost, ServerError>
    
    /** Get  comments to post by post id in Community  */
    func getComments(postId: String, model: CommunityRequestModel) -> AnyPublisher<[CommentResponseModel], ServerError>
    
    /** add  comments to post by post id in Community  */
    func createComment(postId: String, content: String, ids: [String]) -> AnyPublisher<CommentResponseModel, ServerError>
    
    /** add  reply  to comment  by post id and comment id  in Community  */
    func addReply(postId: String, commentId: String, content: String, replyToModel: ReplyToModel, ids: [String]) -> AnyPublisher<ReplyModel, ServerError>
    
    func getPost(_ id: String) -> AnyPublisher<PostData, ServerError>
    
    func searchUser(name: String) -> AnyPublisher<[CommunityUser], ServerError>
}

class CommunityNetworkProvider: NetworkProvider, CommunityNetworkProviderProtocol {
    
    func uploadImage(data: [Data]) -> AnyPublisher<[Attachments], ServerError> {
        return request(.uploadImage(data: data))
            .eraseToAnyPublisher()
    }
    
    func uploadVideo(data: Data) -> AnyPublisher<Attachments, ServerError> {
        return request(.uploadVideo(data: data))
            .eraseToAnyPublisher()
    }
    
    func createPost(model: CreatePostRequestModel) -> AnyPublisher<Post, ServerError> {
        return request(.createPost(model: model))
            .eraseToAnyPublisher()
    }
    
    func createStaticPost(steps: String) -> AnyPublisher<Post, ServerError> {
        return request(.createStaticPost(steps))
            .eraseToAnyPublisher()
    }
    
    func getPosts(model: CommunityRequestModel) -> AnyPublisher<Community, ServerError> {
        return request(.getPosts(model: model))
            .eraseToAnyPublisher()
    }
    
    func deletePost(postId: String) -> AnyPublisher<BaseResponse, ServerError> {
        return request(.deletePost(postId))
            .eraseToAnyPublisher()
    }
    
    func editPost(model: CreatePostRequestModel, postId: String, employees: [String]) -> AnyPublisher<Post, ServerError> {
        var model = model
        model.employees = employees
        return request(.editPost(model: model, postId: postId))
            .eraseToAnyPublisher()
    }
    
    func getShares(postId: String) -> AnyPublisher<[LikeAndShares], ServerError> {
        return request(.getShares(postId))
            .eraseToAnyPublisher()
    }
    
    func addShares() -> AnyPublisher<Post, ServerError> {
        return request(.addShares)
            .eraseToAnyPublisher()
    }
    
    func getLikes(postId: String) -> AnyPublisher<[LikeAndShares], ServerError> {
        return request(.getLikes(postId))
            .eraseToAnyPublisher()
    }
    
    func addRemoveLike(postId: String) -> AnyPublisher<LikePost, ServerError> {
        return request(.addRemoveLike(postId))
            .eraseToAnyPublisher()
    }
    
    func getPost(_ id: String) -> AnyPublisher<PostData, ServerError> {
        return request(.getPost(id: id))
    }
    
    func createComment(postId: String, content: String, ids: [String]) -> AnyPublisher<CommentResponseModel, ServerError> {
        return request(.createComment(content: content, postId: postId, ids: ids))
    }
    
    func getComments(postId: String, model: CommunityRequestModel) -> AnyPublisher<[CommentResponseModel], ServerError> {
        return request(.getComments(model: model, postId: postId))
            .eraseToAnyPublisher()
    }
    
    func addReply(postId: String, commentId: String, content: String, replyToModel: ReplyToModel, ids: [String]) -> AnyPublisher<ReplyModel, ServerError> {
        return request(.addReply(postId: postId, commentId: commentId, content: content, replyToModel: replyToModel, ids: ids))
    }
    
    func searchUser(name: String) -> AnyPublisher<[CommunityUser], ServerError> {
        return request(.searchUser(name: name))
    }

}
