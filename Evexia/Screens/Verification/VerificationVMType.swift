//
//  VerificationVMType.swift
//  Evexia
//
//  Created by  Artem Klimov on 04.07.2021.
//

import Combine

typealias VerificationVMOuput = AnyPublisher<VerificationVCState, Never>

protocol VerificationVMType {
    func transform(input: VerificationVMInput) -> VerificationVMOuput
    func navigateToSignUp()
    
    var email: String { get }
}

struct VerificationVMInput {
    /// triggered when the retry  button did tap
    let retry: AnyPublisher<Void, Never>
    /// triggered when view will appear
    let appear: AnyPublisher<Void, Never>
}

enum VerificationVCState {
    case idle
    case loading
    case failure(ServerError)
    case success
}
