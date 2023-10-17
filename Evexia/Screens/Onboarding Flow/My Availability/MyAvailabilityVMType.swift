//
//  MyAvailabilityVMType.swift
//  Evexia
//
//  Created by  Artem Klimov on 20.07.2021.
//

import Foundation
import Combine

typealias MyAvailabilityVMOuput = AnyPublisher<MyAvailabilityVCState, Never>

protocol MyAvailabilityVMType {
    func transform(input: MyAvailabilityVMInput) -> MyAvailabilityVMOuput
    
    var profileFlow: ProfileEditScreenFlow { get }
}

struct MyAvailabilityVMInput {
    /// called when a screen becomes visible
    let load: AnyPublisher<Void, Never>
    /// called when the duration view did tap
    let setDuration: AnyPublisher<Int?, Never>
    /// triggered when the next button did tap
    let setAvailability: AnyPublisher<Void, Never>
}

enum MyAvailabilityVCState {
    case idle([DaySliderCellModel])
    case loading
    case nextAvailabel(Bool)
    case failure(ServerError)
    case getDuration(Int?)
    case success
}
