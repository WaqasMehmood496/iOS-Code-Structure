//
//  BenefitsVMType.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 20.08.2021.
//

import Combine

typealias BenefitsVMOutput = AnyPublisher<BenefitsVCState, Never>

protocol BenefitsVMType {
    
    func transform(input: BenefitsVMInput) -> BenefitsVMOutput
    func navigate(to benefit: Benefit)
}

struct BenefitsVMInput {
    /// called when a screen becomes visible
    let appear: AnyPublisher<Void, Never>
}

enum BenefitsVCState {
    case idle
    case loading
    case success([Benefit])
    case failure(ServerError)
}
