//
//  SettingsVMType.swift
//  Evexia
//
//  Created by  Artem Klimov on 09.08.2021.
//

import Foundation
import Combine

typealias SettingsVMOuput = AnyPublisher<SettingsVCState, Never>

protocol SettingsVMType {
    func transform(input: SettingsVMInput) -> SettingsVMOuput
    func changeAchievementsApearence(isShow: Bool)
    func setupBiometric(isOn: Bool)
}

struct SettingsVMInput {
    /// called when a screen becomes visible
    let appear: AnyPublisher<Void, Never>
    
    let deleteAccount: AnyPublisher<Void, Never>
    
    let logout: AnyPublisher<Void, Never>
    
    let navigateToSetting: AnyPublisher<Settings, Never>
}

enum SettingsVCState {
    case idle([[Settings]])
    case loading
    case failure(ServerError)
    case failureBiometric(Error)
    case success
}
