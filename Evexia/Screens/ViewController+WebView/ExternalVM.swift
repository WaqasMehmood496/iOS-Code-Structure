//
//  ExternalViewModel.swift
//
//
//
//  Copyright © 2019 Competo. All rights reserved.
//

import Combine
import Foundation

enum WebViewType {
    case signInWithApple
    case signInWithGoogle
    case url(URL)
}

final class ExternalVM: SocialVMType {
    
    // MARK: - Properties
    let webViewtype: WebViewType
    var dismissSocialWebView: PassthroughSubject<Int?, Never>
    private let router: ExternalNavigation
    private let repository: ExternalRepositoryProtocol
    private var cancellables: [AnyCancellable] = []
   
    // MARK: - Init
    init(webViewType: WebViewType, router: ExternalNavigation, repository: ExternalRepositoryProtocol, dismissSocialWebView: PassthroughSubject<Int?, Never>) {
        self.webViewtype = webViewType
        self.router = router
        self.repository = repository
        self.dismissSocialWebView = dismissSocialWebView
    }
    
    // MARK: Methods
    func getType() -> WebViewType {
        return self.webViewtype
    }

    func getTypeUrl() -> URL? {
        switch webViewtype {
        case .signInWithApple:
//            return getUrl(with: "http://18.133.13.117/api/v1/auth/apple")
            return getUrl(with: "https://my-dayapp-server.com/api/v1/auth/apple")
        case .signInWithGoogle:
//            return getUrl(with: "http://18.133.13.117/api/v1/auth/google")
            return getUrl(with: "https://my-dayapp-server.com/api/v1/auth/google")
        case let .url(urlString):
            return urlString
        }
    }
    
    func getTitle() -> String {
        switch webViewtype {
        case .signInWithApple:
            return "Apple Sign In".localized()
        case .signInWithGoogle:
            return "Google Sign In".localized()
        case .url:
            return ""
        }
    }
    
    func showNextVC(aviable: Int?) {
        aviable != nil ? router.showOnboarding() : router.showRoot()
    }
    
    func transform(input: SocialVMInput) -> SocialVMOtput {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        let appleAuthenticate = input
            .sigInWithApple
            .map { [weak self] result -> SocialAuthState in
                switch result {
                case let .success(user):
                    return .appleSignIn(self?.checkRegisterState(user: user))
                case let .failure(error):
                    return .failure(error)
                }
            }
        
        return appleAuthenticate.eraseToAnyPublisher()
    }
    
    func checkRegisterState(user: AuthResponseModel) -> Int? {
        UserDefaults.accessToken = user.accessToken
        UserDefaults.refreshToken = user.refreshToken
        UserDefaults.userModel = user.user
        UserDefaults.email = user.user.email
        UserDefaults.isSocialLoginUser = true
        if user.user.availability.duration == nil || UserDefaults.userModel?.gender == nil {
            UserDefaults.isOnboardingDone = false
            return nil
        } else {
            UserDefaults.isOnboardingDone = true
            return user.user.availability.duration
        }
    }
}

// MARK: - private extensions
extension ExternalVM {
    private func getUrl(with urlString: String) -> URL? {
        URL(string: urlString)
    }
}
