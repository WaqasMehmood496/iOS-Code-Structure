//
//  CountriesVMType.swift
//  Evexia
//
//  Created by Roman Korostenskyi on 29.07.2021.
//

import Combine

typealias CountriesVMOutput = AnyPublisher<CountriesVCState, Never>

protocol CountriesVMType {
    
    func transform(input: CountriesVMInput) -> CountriesVMOutput
    func closeView()
}

struct CountriesVMInput {
    /// called when a screen becomes visible
    let appear: AnyPublisher<Void, Never>
    
    /// Set selected country
    let setCountry: AnyPublisher<String, Never>
}

enum CountriesVCState {
    case idle
    case loading
    case success([CountryCellModel])
    case failure(ServerError)
}

extension CountriesVCState: Equatable {
    static func == (lhs: CountriesVCState, rhs: CountriesVCState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.loading, .loading): return true
        case (.success, .success): return true
        case (.failure, .failure): return true
        default: return false
        }
    }
}
