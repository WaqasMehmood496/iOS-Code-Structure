//
//  FaceTouchIdService.swift
//  Evexia Staging
//
//  Created by Александр Ковалев on 14.11.2022.
//

import Foundation
import BiometricAuthentication
import LocalAuthentication
import Combine

enum CustomBiometricError: Error {
    case disableBiometric
}

// MARK: BiometricdService

class BiometricdService {
    
    static var isNeedAuth: Bool {
        (Date().days(sinceDate: UserDefaults.biometricСonfirmationTime ?? Date()) ?? 0) >= 1 || UserDefaults.biometricСonfirmationTime == nil
    }

    static var isOn: Bool {
        UserDefaults.isFirstAccessToBiometric || KeychainProvider().getBiometricSettings()?.access == true
    }

    static var canAuth: Bool {
        BioMetricAuthenticator.canAuthenticate()
    }
    
    static var isFaceIDAvailable: Bool {
        BioMetricAuthenticator.shared.faceIDAvailable()
    }
    
    static var isTouchIDAvailable: Bool {
        BioMetricAuthenticator.shared.touchIDAvailable()
    }

    private var keychainIsNotNil: Bool {
        KeychainProvider().getBiometricSettings()?.access == true
    }

    static func getBiometricsType() -> LABiometryType {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        return context.biometryType
    }

    func auth(
        isOn: Bool = BiometricdService.isOn,
        publisher: PassthroughSubject<Result<Bool, Error>, Never>
    ) {
        isOn ? authWithBiometric(publisher: publisher) : KeychainProvider().cleanSomeKeychain(with: .userBiometricSettings)
    }
    
    func authWithBiometric(publisher: PassthroughSubject<Result<Bool, Error>, Never>) {

        if BiometricdService.isNeedAuth || !keychainIsNotNil {
            BioMetricAuthenticator.authenticateWithPasscode(reason: "Enter Password") { [weak self] (result) in
                self?.setupBiometricResult(result: result, publisher: publisher)
            }
        } else {
            KeychainProvider().saveSettings(BiometricSettingsModel(type: BiometricdService.isFaceIDAvailable == true ? .faceId : .touchId, access: true))
        }
    }

    private func setupBiometricResult(result: Result<Bool, AuthenticationError>, publisher: PassthroughSubject<Result<Bool, Error>, Never>) {
        switch result {
        case .success(let access):
            KeychainProvider().saveSettings(BiometricSettingsModel(type: BiometricdService.isFaceIDAvailable == true ? .faceId : .touchId, access: access))
            UserDefaults.biometricСonfirmationTime = Date().toZeroTime()
            publisher.send(.success(access))
        case .failure(let error):

            if error == .biometryLockedout {
                let typeBiometric = BiometricdService.isFaceIDAvailable == true ? "Face ID" : "Touch ID"
                let message = "\(typeBiometric) is locked now, because off to many failed attemps. Enter passcode to unlock \(typeBiometric)"
                self.showPasscodeAuthentication(message: message)
                return
            }

            publisher.send(.failure(error))
        }
    }
    
    // show passcode authentication
    private func showPasscodeAuthentication(message: String) {
        
        BioMetricAuthenticator.authenticateWithPasscode(reason: message) { (result) in
            switch result {
            case .success(let access):
                KeychainProvider().saveSettings(BiometricSettingsModel(type: BiometricdService.isFaceIDAvailable == true ? .faceId : .touchId, access: access))
                UserDefaults.biometricСonfirmationTime = Date().toZeroTime()
            case .failure(let error):
                print(error.message())
            }
        }
    }
}


