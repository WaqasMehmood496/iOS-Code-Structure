//
//  MyWhyVMType.swift
//  Evexia
//
//  Created by  Artem Klimov on 19.07.2021.
//

import Foundation
import Combine

typealias MyWhyVMOuput = AnyPublisher<MyWhyVCState, Never>

protocol MyWhyVMType {
    func transform(input: MyWhyVMInput) -> MyWhyVMOuput    
}

struct MyWhyVMInput {
        /// called when a screen becomes visible
        let load: AnyPublisher<Void, Never>
        /// triggered when the next button did tap
        let nextAction: AnyPublisher<Void, Never>
}

enum MyWhyVCState {
    case idle([MyWhyModel])
    case loading
    case nextAvailabel(Bool)
    case failure(ServerError)
    case udpateSelected(count: Int, maxValue: Int)
    case success
}
