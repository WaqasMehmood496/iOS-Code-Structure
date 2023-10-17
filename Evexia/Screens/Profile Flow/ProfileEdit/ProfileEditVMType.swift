//
//  ProfileVMType.swift
//  Evexia
//
//  Created by  Artem Klimov on 28.07.2021.
//

import Foundation
import Combine
import UIKit.UIImage

typealias ProfileVMOuput = AnyPublisher<ProfileEditVCState, Never>

protocol ProfileVEditMType {
    func transform(input: ProfileVMInput) -> ProfileVMOuput
    func navigateToParameters(for: ProfileCellModel)
    
    var profileFlow: ProfileEditScreenFlow { get }
}

struct ProfileVMInput {
    /// called when a screen becomes visible
    let load: AnyPublisher<Void, Never>
    /// triggered when the next button did tap
    let nextAction: AnyPublisher<Void, Never>
    /// called when image choosen for avatar
    let saveAvatar: AnyPublisher<UIImage, Never>
    
    let deleteAvatar: AnyPublisher<Void, Never>
    
    let setGender: AnyPublisher<Gender?, Never>
    
    let navigateToParameter: AnyPublisher<ProfileCellModel, Never>
    
    let finishOnboarding: AnyPublisher<Void, Never>
}

enum ProfileEditVCState {
    case idle(ProfileEditScreenFlow)
    case update([ProfileCellModel])
    case loading
    case setProfileAvailabel(Bool)
    case failure(ServerError)
    case success
    case setAvatar(String?)
    case finishAvailable(Bool)
}
