//
//  SettingsRepository.swift
//  Evexia
//
//  Created by  Artem Klimov on 09.08.2021.
//

import Foundation
import Combine

protocol SettingsRepositoryProtocol {
    func deleteAccount() -> AnyPublisher<Result<Void, ServerError>, Never>
    func logout() -> AnyPublisher<Result<Void, ServerError>, Never>
    func changeAchievements(isOn: Bool)
    func biometricAuthSwitched(isOn: Bool, publisher: PassthroughSubject<Result<Bool, Error>, Never>)
}

class SettingsRepository {
    
    private var userNetworkProvider: UserNetworkProviderProtocol
    private var biometricdService: BiometricdService
    
    init(userNetworkProvider: UserNetworkProviderProtocol, biometricdService: BiometricdService) {
        self.userNetworkProvider = userNetworkProvider
        self.biometricdService = biometricdService
    }
    
    private func cleanUserData() {
        if let domain = Bundle.main.bundleIdentifier {
            let appHealsSync = UserDefaults.appleHealthSync
            let needShowDashBoardTutorial = UserDefaults.needShowDashBoardTutorial
            let isSignUpInProgress = UserDefaults.isSignUpInProgress
            let measurement = UserDefaults.measurement
            let isShowMeasurementPopUp = UserDefaults.isShowMeasurementPopUp
            let isFirstAccessToBiometric = UserDefaults.isFirstAccessToBiometric
            let isFirstAccessiNSettingsToBiometric = UserDefaults.isFirstAccessiNSettingsToBiometric

            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.appleHealthSync = appHealsSync
            UserDefaults.needShowDashBoardTutorial = needShowDashBoardTutorial
            UserDefaults.isSignUpInProgress = isSignUpInProgress
            UserDefaults.isShowMeasurementPopUp = isShowMeasurementPopUp
            UserDefaults.measurement = measurement
            UserDefaults.isFirstAccessToBiometric = isFirstAccessToBiometric
            UserDefaults.isFirstAccessiNSettingsToBiometric = isFirstAccessiNSettingsToBiometric
        }
    }
    
    deinit {
        Log.info("deinit -> \(self)")
    }
    
}

extension SettingsRepository: SettingsRepositoryProtocol {
    func deleteAccount() -> AnyPublisher<Result<Void, ServerError>, Never> {
        return self.userNetworkProvider.deleteAccount()
            .map { [weak self] _ in
                self?.cleanUserData()
                return .success(())
            }
            .catch { serverError -> AnyPublisher<Result<Void, ServerError>, Never> in
                return .just(.failure(serverError))
            }
            .eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<Result<Void, ServerError>, Never> {
        return self.userNetworkProvider.logout()
            .map { [weak self] _ in
                self?.cleanUserData()
                return .success(())
            }
            .catch { [weak self] error -> AnyPublisher<Result<Void, ServerError>, Never> in
                self?.cleanUserData()
                return .just(.failure(error))
            }
            .eraseToAnyPublisher()
    }
    
    func changeAchievements(isOn: Bool) {
        self.userNetworkProvider.changeAchievementsApearance(isOn: isOn)
            .sink { _ in
            } receiveValue: { model in
                UserDefaults.isShowAchieve = model.isShownAchievements
            }
    }
    
    func biometricAuthSwitched(isOn: Bool, publisher: PassthroughSubject<Result<Bool, Error>, Never>) {
        biometricdService.auth(isOn: isOn, publisher: publisher)
    }
}
