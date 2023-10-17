//
//  AdviseVMType.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 17.08.2021.
//

import Combine

typealias AdviseVMOutput = AnyPublisher<AdviseVCState, Never>

protocol AdviseVMType {
    
    func transform(input: AdviseVMInput) -> AdviseVMOutput
    func applyNavigation(for: AdviseModel)
}

struct AdviseVMInput {
    
    let appear: AnyPublisher<Void, Never>
}

enum AdviseVCState {
    case idle([[AdviseModel]])
    case loading
    case success
    case failure(ServerError)
}
