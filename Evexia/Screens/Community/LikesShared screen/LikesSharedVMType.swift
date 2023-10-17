//
//  LikesSharedVMType.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 09.09.2021.
//

import Combine

// MARK: - LikesSharedStartVCType
enum LikesSharedStartVCType {
    case likes
    case shares
}

// MARK: - LikesSharedVMOutput
typealias LikesSharedVMOutput = AnyPublisher<LikesSharedVCState, Never>

// MARK: - LikesSharedVMType
protocol LikesSharedVMType {
    var startVCType: LikesSharedStartVCType { get }
    
    func transform(input: LikesSharedVMInput) -> LikesSharedVMOutput
}

// MARK: - LikesSharedVMInput
struct LikesSharedVMInput {
    let appear: AnyPublisher<LikesSharedStartVCType, Never>
}

// MARK: - LikesSharedVCState
enum LikesSharedVCState {
    case idle
    case success([LikeAndShares])
    case failure(ServerError)
}
