//
//  ExternalVMType.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 01.09.2021.
//

import Combine
import UIKit

typealias SocialVMOtput = AnyPublisher<SocialAuthState, Never>

protocol SocialVMType {
    func transform(input: SocialVMInput) -> SocialVMOtput
    func checkRegisterState(user: AuthResponseModel) -> Int?
    func getTitle() -> String
    func getTypeUrl() -> URL?
    
    var dismissSocialWebView: PassthroughSubject<Int?, Never> { get set }
    var webViewtype: WebViewType { get }
}

struct SocialVMInput {
    /// triggered when when the model came
    let sigInWithApple: AnyPublisher<Result<AuthResponseModel, ServerError>, Never>
}

enum SocialAuthState {
    case appleSignIn(Int?)
    case failure(ServerError)
}

extension SocialAuthState: Equatable {
    static func == (lhs: SocialAuthState, rhs: SocialAuthState) -> Bool {
        switch (lhs, rhs) {
        case (.failure, .failure): return true
        default: return false
        }
    }
}
