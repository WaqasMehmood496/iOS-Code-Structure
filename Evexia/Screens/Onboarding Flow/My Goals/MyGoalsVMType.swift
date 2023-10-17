//
//  MyGoalsVMType.swift
//  Evexia
//
//  Created by  Artem Klimov on 20.07.2021.
//

import Foundation
import Combine

typealias MyGoalsVMOuput = AnyPublisher<MyGoalsVCState, Never>

protocol MyGoalsVMType {
    var reconfigCellModel: PassthroughSubject<[FocusSection], Never> { get set }
    
    func transform(input: MyGoalsVMInput) -> MyGoalsVMOuput
}

struct MyGoalsVMInput {
        /// called when a screen becomes visible
        let load: AnyPublisher<Void, Never>
        /// triggered when the next button did tap
        let nextAction: AnyPublisher<Void, Never>
}

enum MyGoalsVCState {
    case idle([FocusSection])
    case loading
    case nextAvailabel(Bool)
    case failure(ServerError)
    case success
}

extension MyGoalsVCState: Equatable {
    static func == (lhs: MyGoalsVCState, rhs: MyGoalsVCState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.loading, .loading): return true
        case (.success, .success): return true
        case (.failure, .failure): return true
        case let (.nextAvailabel(a), .nextAvailabel(b)): return a == b
        default: return false
        }
    }
}
