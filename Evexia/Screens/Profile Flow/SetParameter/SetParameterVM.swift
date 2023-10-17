//
//  SetParameterVM.swift
//  Evexia
//
//  Created by  Artem Klimov on 30.07.2021.
//

import Foundation
import Combine

class SetParameterVM {
    
    var repository: SetParameterRepositoryProtocol
    let type: ProfileSettingsType
    var firstName = CurrentValueSubject<String, Never>("")
    var lastName = CurrentValueSubject<String, Never>("")
    var email = CurrentValueSubject<String, Never>("")
    var weight = CurrentValueSubject<String, Never>("")
    var height = CurrentValueSubject<String, Never>("")
    var sleep = CurrentValueSubject<String, Never>("")
    var age = CurrentValueSubject<String, Never>("")
    var userModel = CurrentValueSubject<User?, Never>(nil)
    
    var errorPublisher = PassthroughSubject<ServerError, Never>()
    var isRequestAction = PassthroughSubject<Bool, Never>()
    private var router: SetParameterNavigation
    private var cancellables = Set<AnyCancellable>()

    init(router: SetParameterNavigation, repository: SetParameterRepositoryProtocol, model: ProfileCellModel) {
        self.router = router
        self.repository = repository
        self.type = model.type
        self.userModel.send(UserDefaults.userModel)
    }
    
    var isSaveAvailabel: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest4(Publishers.CombineLatest(firstName, lastName), email, Publishers.CombineLatest3(age, weight, height), userModel)
            .map { [weak self] name, email, parameters, user -> Bool in
                let (firstName, lastName) = name
                let (age, weight, height) = parameters
                switch self?.type {
                case .email:
                    return email.isValidEmail && email != user?.email
                case .name:
                    return (firstName.isValidName && lastName.isValidName) && (firstName != user?.firstName || lastName != user?.lastName)
                    
                case .weight:
                    let availabel = weight.isValidWeight && weight != user?.weight
                    return isMetricSystem ? availabel : weight != user?.weight
                case .height:
                    let availabel = height.isValidHeight && height != user?.height
                    return isMetricSystem ? availabel : height != user?.height
                case .age:
                    return age.isValidAge && age != user?.age
                default:
                    return false
                }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func saveChanges() {
        switch type {
        case .weight:
            self.udpateWeight()
        default:
            self.udpateProfile()
        }
    }
    
    private func udpateWeight() {
        self.isRequestAction.send(true)
        let date = self.getStartOfDay()
        let weight = isMetricSystem ? weight.value : weight.value.changeMeasurementSystem(unitType: .mass, manualMeasurement: (UnitMass.stones, UnitMass.kilograms)).value
        let model = UpdateWeightModel(value: weight, date: date)
        self.repository.updateWeight(to: model)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case let .failure(serverError):
                    self?.errorPublisher.send(serverError)
                default:
                    break
                }
                self?.isRequestAction.send(false)
            }, receiveValue: { [weak self] _ in
                self?.isRequestAction.send(false)
                self?.router.closeView()
            }).store(in: &self.cancellables)
    }
    
    private func udpateProfile() {
        let height = isMetricSystem ? height.value : height.value.changeMeasurementSystem(unitType: .lengh, manualMeasurement: (UnitLength.feet, UnitLength.centimeters)).value
        let updateModel = UpdateProfileModel(email: self.email.value,
                                             firstName: self.firstName.value,
                                             lastName: self.lastName.value,
                                             country: self.userModel.value?.country ?? "",
                                             gender: self.userModel.value?.gender?.rawValue ?? "",
                                             height: height,
                                             sleep: self.sleep.value,
                                             heartRate: nil,
                                             age: self.age.value)
        self.isRequestAction.send(true)

        self.repository.updateProfile(to: updateModel)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case let .failure(serverError):
                    self?.errorPublisher.send(serverError)
                default:
                    break
                }
                self?.isRequestAction.send(false)
            }, receiveValue: { [weak self] _ in
                self?.isRequestAction.send(false)
                self?.router.closeView()
            }).store(in: &self.cancellables)
    }
    
    private func getStartOfDay() -> Int {
       return Int(Date().toZeroTime().timeMillis)
    }
}
