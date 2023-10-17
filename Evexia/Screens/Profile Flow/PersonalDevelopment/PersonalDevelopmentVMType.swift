//
//  PersonalDevelopmentVMType.swift
//  Evexia Staging
//
//  Created by Oleg Pogosian on 07.12.2021.
//

import Foundation
import Combine

typealias PersonalDevelopmentVMOutput = AnyPublisher<PersonalDevelopmentVCState, Never>

protocol PersonalDevelopmentVMType {
    
    func transform(input: PersonalDevelopmentVMInput) -> PersonalDevelopmentVMOutput
    func applyNavigation(id: Int, title: String)
}

struct PersonalDevelopmentVMInput {
    let appear: AnyPublisher<Void, Never>
}

enum PersonalDevelopmentVCState {
    case idle(PersonalDevCategory)
    case loading
    case success
    case failure(ServerError)
}
