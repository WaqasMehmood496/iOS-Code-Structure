//
//  ProfileVM.swift
//  Evexia
//
//  Created by  Artem Klimov on 28.07.2021.
//

import Foundation
import Combine

class ProfileEditVM: ProfileVEditMType {
    var router: ProfileEditRouter
    var repository: ProfileEditRepositoryProtocol
    let profileFlow: ProfileEditScreenFlow
    
    init(router: ProfileEditRouter, repository: ProfileEditRepositoryProtocol, profileFlow: ProfileEditScreenFlow) {
        self.router = router
        self.repository = repository
        self.profileFlow = profileFlow
    }
    
    deinit {
        Log.info("deinit -----> \(self)")
    }
    
    func transform(input: ProfileVMInput) -> ProfileVMOuput {
        
        let setAvatar = self.repository.imageURL
            .map({ avatar -> ProfileEditVCState in
                return .setAvatar(avatar)
            }).eraseToAnyPublisher()
        
        let idle: AnyPublisher<ProfileEditVCState, Never> = .just(ProfileEditVCState.idle(self.profileFlow))
        
        let update = self.repository.dataSource
            .map { models -> ProfileEditVCState in
                return .update(models)
            }.eraseToAnyPublisher()
        
        let setGender = input.setGender
            .flatMap { gender -> AnyPublisher<Result<Void, ServerError>, Never> in
                return self.repository.setGender(to: gender)
            }.map({ result -> ProfileEditVCState in
                switch result {
                case let .failure(serverError):
                    return .failure(serverError)
                case .success:
                    return .success
                }
            }).eraseToAnyPublisher()
         
        let saveAvatar = input.saveAvatar
            .flatMap { [weak self] image -> AnyPublisher<Result<Void, ServerError>, Never> in
                guard let imageData = image.jpegData(compressionQuality: 0.5), let self = self else { return .empty() }
                return self.repository.saveUserAvatar(imageData: imageData)
            }.map({ result -> ProfileEditVCState in
                switch result {
                case let .failure(serverError):
                    return .failure(serverError)
                case .success:
                    return .success
                }
            }).eraseToAnyPublisher()
        
        let deleteAvatar = input.deleteAvatar
            .flatMap { [weak self] _ -> AnyPublisher<Result<Void, ServerError>, Never> in
                guard let self = self else { return .empty() }
                return self.repository.deleteAvatar()
            }.map({ result -> ProfileEditVCState in
                switch result {
                case let .failure(serverError):
                    return .failure(serverError)
                case .success:
                    return .success
                }
            }).eraseToAnyPublisher()
        
        let finishAvailabel = self.repository.isFinishAvailabel
            .map { isAvailabel -> ProfileEditVCState in
                return .finishAvailable(isAvailabel)
            }.eraseToAnyPublisher()
                
        let finishOnboarding = input.finishOnboarding
            .map { [weak self] _ -> ProfileEditVCState in
                UserDefaults.isOnboardingDone = true
                self?.router.navigateToRoot()
                return .success
            }.eraseToAnyPublisher()
        
        return Publishers.MergeMany(update, saveAvatar, setAvatar, setGender, finishAvailabel, idle, deleteAvatar, finishOnboarding).eraseToAnyPublisher()
    }
    
    func navigateToParameters(for model: ProfileCellModel) {
        switch model.type {
        case .country:
            self.router.navigateToCountries(model: model)
        case .availability:
            self.router.navigateToMyAvailability()
        default:
            self.router.navigateToSetParameter(model: model)
        }
    }
}
