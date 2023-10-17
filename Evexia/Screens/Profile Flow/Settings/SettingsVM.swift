//
//  SettingsVM.swift
//  Evexia
//
//  Created by  Artem Klimov on 09.08.2021.
//

import Foundation
import Combine

class SettingsVM: SettingsVMType {
    
    // MARK: - Properties
    private let repository: SettingsRepositoryProtocol
    private var router: SettingsNavigation
    private var cancellables: [AnyCancellable] = []
    
    private let biometricPublisher = PassthroughSubject<Result<Bool, Error>, Never>()
        
    init(router: SettingsNavigation, repository: SettingsRepositoryProtocol) {
        self.router = router
        self.repository = repository
    }
    
    func transform(input: SettingsVMInput) -> SettingsVMOuput {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        let idle = input.appear
            .map { [weak self] _ -> SettingsVCState in
                let data = self?.generateDataSource()
                return .idle(data ?? [])
            }.eraseToAnyPublisher()
        
        let deleteAccount = input.deleteAccount
            .flatMap { [weak self] _ -> AnyPublisher<Result<Void, ServerError>, Never> in
                guard let self = self else { return .empty() }
                return self.repository.deleteAccount()
            }
            .receive(on: DispatchQueue.main)
            .map { [weak self] result -> SettingsVCState in
                switch result {
                case let .failure(serverError):
                    return .failure(serverError)
                case .success:
                    self?.router.navigateToSignUp()
                    return .success
                }
            }.eraseToAnyPublisher()
        
        let logout = input.logout
            .flatMap { [weak self] _ -> AnyPublisher<Result<Void, ServerError>, Never> in
                guard let self = self else { return .empty() }
                return self.repository.logout()
            }
            .receive(on: DispatchQueue.main)
            .map { [weak self] _ -> SettingsVCState in
                self?.router.navigateToSignIn()
                return .success
            } .eraseToAnyPublisher()
        
        let navigation = input.navigateToSetting
            .receive(on: DispatchQueue.main)
            .map { [weak self] setting -> SettingsVCState  in
                switch setting {
                case .termsOfUse:
                    guard let terms = URL(string: "https://www.my-dayapp.com/terms-and-conditions") else {
                        self?.router.navigateToAgreements(type: .termsOfUse)
                        return .success
                    }
                    self?.router.open(terms)
                case .privacyPolicy:
                    guard let privacy = URL(string: "https://www.my-dayapp.com/privacy") else {
                        self?.router.navigateToAgreements(type: .privacyPolicy)
                        return .success
                    }
                    self?.router.open(privacy)
                case .measurementSystem:
                    self?.router.showMeasurementSystem()
                case .passwordCahnge:
                    self?.router.navigateToPasswordChange()
                default:
                    break
                }
                return .success
            }.eraseToAnyPublisher()
        
        let biometric = biometricPublisher
            .map { result -> SettingsVCState in
                switch result {
                case .failure(let error):
                    return .failureBiometric(error)
                case .success(_):
                    return .success
                }
            }.eraseToAnyPublisher()
            
        return Publishers.Merge5(deleteAccount, idle, logout, navigation, biometric).eraseToAnyPublisher()
    }
    
    private func generateDataSource() -> [[Settings]] {
        let helpSettings: [Settings] = [.privacyPolicy, .termsOfUse, .helpCenter, .contacts, .gamefication, .faceTouchId, .measurementSystem]
        var accountSettings: [Settings] = [.logout, .delete]
        if !UserDefaults.isSocialLoginUser {
            accountSettings.insert(.passwordCahnge, at: 0)
        }
        return [helpSettings, accountSettings]
    }
    
    func changeAchievementsApearence(isShow: Bool) {
        self.repository.changeAchievements(isOn: isShow)
    }
    
    func setupBiometric(isOn: Bool) {
        repository.biometricAuthSwitched(isOn: isOn, publisher: biometricPublisher)
    }
}
