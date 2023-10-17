//
//  RedirectService.swift
//  Evexia
//
//  Created by  Artem Klimov on 22.07.2021.
//

import Foundation
import Swinject
import Combine

class RedirectService {
    
    private var window: UIWindow?
    private var injector: Container
    private var deepLinkManager: DeepLinksManagerUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    private var userNetworkProvider: UserNetworkProviderProtocol
    
    init(with window: UIWindow, injector: Container, deepLinkManager: DeepLinksManagerUseCaseProtocol) {
        self.window = window
        self.injector = injector
        self.deepLinkManager = deepLinkManager
        self.userNetworkProvider = injector.resolve(UserNetworkProvider.self)!
        self.binding()
    }
    
    private func binding() {
        self.deepLinkManager.deepLinkPresentedInfo
            .sink(receiveValue: { [weak self] deepLinkModel in
                guard let link = deepLinkModel else { return }
                self?.openDeepLink(with: link)
            }).store(in: &self.cancellables)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(self.logoutNotification(notification:)), name: Notification.Name("Logout"), object: nil)
//
////        NotificationCenter.default
//            .publisher(for: UIApplication.didBecomeActiveNotification)
//            .flatMap { [unowned self] _ -> AnyPublisher<Result<RefreshTokenResponseModel, ServerError>, Never> in
//                return self.userNetworkProvider.refreshToken()
//                    .map { responseModel -> Result<RefreshTokenResponseModel, ServerError> in
//                        UserDefaults.accessToken = responseModel.accessToken
//                        UserDefaults.refreshToken = responseModel.refreshToken
//                        return .success(responseModel)
//                    }
//                    .catch { serverError -> AnyPublisher<Result<RefreshTokenResponseModel, ServerError>, Never> in
//                        return .just(.failure(serverError))
//                    }.eraseToAnyPublisher()
//            }
//            .receive(on: DispatchQueue.main)
//            .sink( receiveValue: { [weak self] result in
//                switch result {
//                case .success:
//                    return
//                case .failure:
//                    self?.logout()
//                }
//            }).store(in: &cancellables)
//
//        NotificationCenter.default
//            .publisher(for: UIApplication.didBecomeActiveNotification)
//                .flatMap { [unowned self] _ -> AnyPublisher<Result<User, ServerError>, Never> in
//                    return self.userNetworkProvider.getUserProfile()
//                        .map { responseModel -> Result<User, ServerError> in
//                            UserDefaults.userModel = responseModel
//                            return .success(responseModel)
//                        }
//                        .catch { serverError -> AnyPublisher<Result<User, ServerError>, Never> in
//                            return .just(.failure(serverError))
//                        }.eraseToAnyPublisher()
//                }
//                .receive(on: DispatchQueue.main)
//                .sink( receiveValue: { _ in
//                    return
//                }).store(in: &cancellables)
    }
    
    private func openDeepLink(with model: DeepLinkModel) {
        let rootController = window?.rootViewController as? UINavigationController
        guard rootController != nil else {
            // openDeepLinkWith(notification: model)
            return
        }
        switch model {
        case let .forgotPassword(token):
            let controller = SetPasswordBuilder.build(injector: injector, token: token)
            guard var viewControllers = rootController?.viewControllers, viewControllers.last as? SetPasswordVC != nil else {
                rootController?.pushViewController(controller, animated: true)
                return
            }
            _ = viewControllers.popLast()
            viewControllers.append(controller)
            rootController?.setViewControllers(viewControllers, animated: true)
            
        case let .verification(token):
            guard let isSignUpInProgress = UserDefaults.isSignUpInProgress, isSignUpInProgress == true else {
                logout()
                return
            }
            
            guard let email = UserDefaults.email else {
                logout()
                return
            }
            
            if isSignUpInProgress {
                UserDefaults.verificationToken = token
                return
            }
            
            guard rootController?.visibleViewController is VerificationVC else {
                let controller = VerificationBuilder.build(injector: injector, email: email)
                rootController?.pushViewController(controller, animated: true)
                UserDefaults.verificationToken = token
                return
            }
            UserDefaults.verificationToken = token
        default: break
        }
    }
    
//    func setRootVC() -> UIViewController {
//        guard let token = UserDefaults.accessToken, !token.isEmpty else {
//            let isSignUpInProgress = UserDefaults.isSignUpInProgress ?? false
//            guard let email = UserDefaults.email else {
//                return UINavigationController(rootViewController: SignInBuilder.build(injector: self.injector))
//            }
//            if isSignUpInProgress {
//                return UINavigationController(rootViewController: VerificationBuilder.build(injector: injector, email: email))
//            }
//            return UINavigationController(rootViewController: SignInBuilder.build(injector: injector))
//        }
//        if UserDefaults.isOnboardingDone {
//            return RootBuilder.build(injector: injector)
//        }
//        return UINavigationController(rootViewController: OnboardingRootBuilder.build(injector: injector, profileFlow: .onboarding))
//    }
    
    private func logout() {
        guard UserDefaults.accessToken != nil, !(UserDefaults.isSignUpInProgress ?? false) else { return }
        
        if let domain = Bundle.main.bundleIdentifier {
            let appHealsSync = UserDefaults.appleHealthSync
            let needShowDashBoardTutorial = UserDefaults.needShowDashBoardTutorial
            let isSignUpInProgress = UserDefaults.isSignUpInProgress
            let verificationToken = UserDefaults.verificationToken
            let isFirstAccessToBiometric = UserDefaults.isFirstAccessToBiometric
            let isFirstAccessiNSettingsToBiometric = UserDefaults.isFirstAccessiNSettingsToBiometric

            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.appleHealthSync = appHealsSync
            UserDefaults.needShowDashBoardTutorial = needShowDashBoardTutorial
            UserDefaults.isSignUpInProgress = isSignUpInProgress
            UserDefaults.verificationToken = verificationToken
            UserDefaults.isFirstAccessToBiometric = isFirstAccessToBiometric
            UserDefaults.isFirstAccessiNSettingsToBiometric = isFirstAccessiNSettingsToBiometric
        }
        let signInVC = SignInBuilder.build(injector: injector)
        window?.rootViewController = UINavigationController(rootViewController: signInVC)
    }
    
    @objc
    func logoutNotification(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.logout()
        }
    }
}
