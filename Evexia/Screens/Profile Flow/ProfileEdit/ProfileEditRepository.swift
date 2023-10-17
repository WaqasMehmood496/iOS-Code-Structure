//
//  ProfileRepository.swift
//  Evexia
//
//  Created by  Artem Klimov on 28.07.2021.
//

import Foundation
import Combine

protocol ProfileEditRepositoryProtocol {
    func saveUserAvatar(imageData: Data) -> AnyPublisher<Result<Void, ServerError>, Never>
    func setGender(to gender: Gender?) -> AnyPublisher<Result<Void, ServerError>, Never>
    func deleteAvatar() -> AnyPublisher<Result<Void, ServerError>, Never>
    
    var imageURL: CurrentValueSubject<String?, Never> { get }
    var dataSource: CurrentValueSubject<[ProfileCellModel], Never> { get set }
    var isFinishAvailabel: CurrentValueSubject<Bool, Never> { get }
}

class ProfileEditRepository {
    private var userNetworkProvider: UserNetworkProviderProtocol
    var dataSource = CurrentValueSubject<[ProfileCellModel], Never>([])
    private var cancellables = Set<AnyCancellable>()
    var imageURL = CurrentValueSubject<String?, Never>(nil)
    let profileFlow: ProfileEditScreenFlow
    var isFinishAvailabel = CurrentValueSubject<Bool, Never>(false)
    var userModel: User?
    
    init(userNetworkProvider: UserNetworkProviderProtocol, profileFlow: ProfileEditScreenFlow) {
        self.userNetworkProvider = userNetworkProvider
        self.profileFlow = profileFlow
        self.binding()
    }
    
    deinit {
        Log.info("deinit -----> \(self)")
    }
    
    private func binding() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.updateDataSource(with: UserDefaults.userModel)
            self?.imageURL.send(UserDefaults.userModel?.avatar?.fileUrl)
        }

        UserDefaults.$userModel
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .sink(receiveValue: { [weak self] userModel in
                self?.userModel = userModel
                self?.updateDataSource(with: userModel)
                self?.isProfileSetted(with: userModel)
            }).store(in: &self.cancellables)
    }
    
    private func isProfileSetted(with model: User?) {
        guard let userModel = model else { return }
        
        let isSetted = !userModel.firstName.isEmpty &&
            !userModel.lastName.isEmpty &&
            !userModel.gender.isNil &&
            !userModel.country.isEmpty &&
            !userModel.age.isEmpty
        self.isFinishAvailabel.send(isSetted)
    }
    
    private func updateDataSource(with user: User?) {
        guard let userModel = user else { return }
        let settings = self.profileFlow == .onboarding ? ProfileSettingsType.onboardingSettings : ProfileSettingsType.editProfileSettings
        let items = settings.map { item -> ProfileCellModel in
            switch item {
            case .email:
                return ProfileCellModel(value: userModel.email, type: item)
            case .name:
                return ProfileCellModel(value: !userModel.firstName.isEmpty ?  userModel.firstName + " " + userModel.lastName :  "Not set", type: item)
            case .country:
                return ProfileCellModel(value: !userModel.country.isEmpty ? userModel.country: "Not set", type: item)
            case .gender:
                return ProfileCellModel(value: userModel.gender?.title ?? "Not set", type: item)
            case .age:
                return ProfileCellModel(value: !userModel.age.isEmpty ? userModel.age + " years" : "Not set", type: item)
            case .weight:
                return ProfileCellModel(value: !userModel.weight.isEmpty ? userModel.weight.getUnitWithSybmols(unitType: .mass) : "Not set", type: item)
            case .height:
                return ProfileCellModel(value: !userModel.height.isEmpty ? userModel.height.getUnitWithSybmols(unitType: .lengh) : "Not set", type: item)
            case .availability:
                let availability = (user?.availability.calendar.dictionary as? [String: Int])?
                    .filter { $0.value != 0 }
                    .compactMap { Days(rawValue: $0.key) }
                    .sorted()
                    .map { $0.title }
                    .joined(separator: ", ") ?? "Not set"
                
                return ProfileCellModel(value: availability, type: item)
            case .sleep:
                return ProfileCellModel(value: !userModel.sleep.isEmpty ? userModel.sleep + " h" : "08:00 h", type: item)
            }
        }
        self.dataSource.send(items)
    }
}

extension ProfileEditRepository: ProfileEditRepositoryProtocol {
    
    func saveUserAvatar(imageData: Data) -> AnyPublisher<Result<Void, ServerError>, Never> {
        return self.userNetworkProvider.setAvatar(data: imageData)
            .handleEvents(receiveOutput: { avatar in
                UserDefaults.userModel?.avatar = Avatar(fileUrl: avatar.fileUrl)
            })
            .map { _ in .success(()) }
            .catch { serverError -> AnyPublisher<Result<Void, ServerError>, Never> in
                return .just(.failure(serverError))
            }
            .eraseToAnyPublisher()
    }
    
    func deleteAvatar() -> AnyPublisher<Result<Void, ServerError>, Never> {
        return self.userNetworkProvider.deleteAvatar()
            .handleEvents(receiveOutput: { _ in
                UserDefaults.userModel?.avatar = nil
            })
            .map { _ in .success(()) }
            .catch { serverError -> AnyPublisher<Result<Void, ServerError>, Never> in
                return .just(.failure(serverError))
            }
            .eraseToAnyPublisher()
    }
    
    func setGender(to gender: Gender?) -> AnyPublisher<Result<Void, ServerError>, Never> {
        UserDefaults.userModel?.gender = gender
        let updateModel = UpdateProfileModel(email: self.userModel?.email ?? "",
                                             firstName: self.userModel?.firstName ?? "",
                                             lastName: self.userModel?.lastName ?? "",
                                             country: self.userModel?.country ?? "",
                                             gender: self.userModel?.gender?.rawValue ?? "",
                                             height: self.userModel?.height ?? "",
                                             sleep: self.userModel?.sleep ?? "",
                                             heartRate: self.userModel?.heartRate,
                                             age: self.userModel?.age ?? "" )
        
        return self.userNetworkProvider.updateProfile(with: updateModel)
            .map { _ in .success(()) }
            .catch { serverError -> AnyPublisher<Result<Void, ServerError>, Never> in
                return .just(.failure(serverError))
            }
            .eraseToAnyPublisher()
    }
}
