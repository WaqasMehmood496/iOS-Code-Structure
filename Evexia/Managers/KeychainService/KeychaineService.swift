//
//  KeychainService.swift
//  Evexia
//
//  Created by admin on 17.10.2022.
//

import KeychainSwift
import Combine

enum KeychainItemKeys: String, CaseIterable {
    case userCreds = "user_creds"
    case userBiometricSettings = "user_biometric_settings"
}

// MARK: - KeychainProvider
class KeychainProvider {
    
    private let keychain = KeychainSwift()

    private func getObject<T: Decodable>(modelType: T.Type, by key: KeychainItemKeys) -> AnyPublisher<T, DatabaseError> {
        guard let data = keychain.getData(key.rawValue), let model = try? JSONDecoder().decode(modelType, from: data) else {
            return .fail(DatabaseError.saveFailed("No data"))
        }
        return .just(model)
    }
    
    private func getDecodableObject<T: Decodable>(modelType: T.Type, by key: KeychainItemKeys) -> T? {
        guard let data = keychain.getData(key.rawValue), let model = try? JSONDecoder().decode(modelType, from: data) else {
            return nil
        }
        return model
    }
    
    private func setEncodableObject<T: Encodable>(model: T, by key: KeychainItemKeys) {
        guard let data = try? JSONEncoder().encode(model) else { return }
        keychain.set(data, forKey: key.rawValue)
    }
}

// MARK: - KeychainStorageCleanUseCase
extension KeychainProvider: KeychainStorageCleanUseCase {
    
    func cleanKeychain() -> AnyPublisher<Empty<Any, Never>, Never> {
        for item in KeychainItemKeys.allCases {
            self.keychain.delete(item.rawValue)
        }
        
        return Just.empty()
    }
    
    func cleanSomeKeychain(with key: KeychainItemKeys) {
        keychain.delete(key.rawValue)
        
        if key == .userBiometricSettings {
            UserDefaults.biometricСonfirmationisOn = false
        }
    }
}

// MARK: - KeychainProvider: KeychainBiometricSettingsUseCase
extension KeychainProvider: KeychainBiometricSettingsUseCase {
    
    func saveSettings(_ model: BiometricSettingsModel) {
        self.setEncodableObject(model: model, by: .userBiometricSettings)
        UserDefaults.biometricСonfirmationisOn = true
    }
    
    func getBiometricSettings() -> BiometricSettingsModel? {
        return self.getDecodableObject(modelType: BiometricSettingsModel.self, by: .userBiometricSettings)
    }
}

// MARK: - KeychainStorageCleanUseCase
protocol KeychainStorageCleanUseCase {
    
    /**
     Clean all records in keychain data storage
     */
    func cleanKeychain() -> AnyPublisher<Empty<Any, Never>, Never>
}

protocol KeychainBiometricSettingsUseCase {
    func saveSettings(_ model: BiometricSettingsModel)
    
    func getBiometricSettings() -> BiometricSettingsModel?
}
